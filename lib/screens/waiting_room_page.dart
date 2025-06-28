import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'package:screen_share_plugin/screen_share_plugin.dart';

// const String serverUrl = 'http://192.168.1.23:3000';
// const String livekitUrl = 'ws://192.168.1.23:7880';
// Consider moving serverUrl and livekitUrl to a separate config file
final serverUrl = dotenv.env['SERVER_URL'];
final livekitUrl = dotenv.env['LIVEKIT_URL'];

class WaitingRoomPage extends StatefulWidget {
  final String roomId;
  final String password;
  final String userIdentity;
  final bool isHost;

  const WaitingRoomPage({
    Key? key,
    required this.roomId,
    required this.password,
    required this.userIdentity,
    required this.isHost,
  }) : super(key: key);

  @override
  _WaitingRoomPageState createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  Room? _room;
  List<String> _participantNames = [];
  LocalVideoTrack? _screenShareTrack;
  LocalTrackPublication? _screenSharePublication;

  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack; // Add to your state
  bool _callStarted = false;

  final Map<String, VideoTrack> _remoteVideoTracks = {}; // NEW

  LocalTrackPublication? _audioPublication;
  LocalTrackPublication? _videoPublication;
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await _requestPermissions();
    await _connectToRoom();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<String> _fetchToken() async {
    final response = await http.get(
      Uri.parse(
        '$serverUrl/api/livekit-token?room_id=${widget.roomId}&identity=${widget.userIdentity}&password=${widget.password}',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to fetch token');
    }
  }

  Future<void> _connectToRoom() async {
    final token = await _fetchToken();
    final room = Room();

    room.events.listen(_onRoomEvent);

    await room.connect(livekitUrl!, token);

    print('Connected to LiveKit room: ${room.name}');

    _updateParticipantList(room);
    for (var remoteParticipant in room.remoteParticipants.values) {
      for (var pub in remoteParticipant.videoTrackPublications) {
        if (pub.subscribed && pub.track != null && pub.track is VideoTrack) {
          print(
            'Adding existing remote video track: ${remoteParticipant.identity}',
          );
          _remoteVideoTracks[remoteParticipant.identity] =
              pub.track as VideoTrack;
        }
      }
    }

    setState(() {
      _room = room;
    });
  }

  void _onRoomEvent(RoomEvent event) {
    if (event is ParticipantConnectedEvent ||
        event is ParticipantDisconnectedEvent) {
      _updateParticipantList(_room!);
    } else if (event is DataReceivedEvent) {
      final msg = utf8.decode(event.data);
      print('Received DataTrack message: $msg');
      if (msg == 'start_call' && !_callStarted) {
        _startPublishing();
      }
    } else if (event is TrackSubscribedEvent) {
      if (event.track is VideoTrack) {
        print('Remote video track subscribed: ${event.participant.identity}');
        setState(() {
          _remoteVideoTracks[event.participant.identity] =
              event.track as VideoTrack;
        });
      }
    } else if (event is ParticipantDisconnectedEvent) {
      print('Participant disconnected: ${event.participant.identity}');
      setState(() {
        _remoteVideoTracks.remove(event.participant.identity);
      });
    }
  }

  void _updateParticipantList(Room room) {
    List<String> names = [];

    // Add local participant first:
    if (room.localParticipant != null) {
      names.add(room.localParticipant!.identity);
    }

    // Add remote participants:
    // Add remote participants:
    room.remoteParticipants.values.forEach((p) {
      names.add(p.identity);
    });

    setState(() {
      _participantNames = names;
    });

    print('Current participants: $_participantNames');
  }

  Future<void> _startScreenShare() async {
    try {
      final screenTrack = await LocalVideoTrack.createScreenShareTrack();

      if (screenTrack != null) {
        final pub = await _room?.localParticipant?.publishVideoTrack(
          screenTrack,
        );
        setState(() {
          _screenShareTrack = screenTrack;
          _screenSharePublication = pub;
        });
      }
    } catch (e) {
      print('Failed to start screen share: $e');
    }
  }

  Future<void> _stopScreenShare() async {
    if (_screenShareTrack != null) {
      await _screenShareTrack!.stop(); // this unpublishes as well
      setState(() {
        _screenShareTrack = null;
      });
    }
  }

  void _sendStartCall() {
    _room?.localParticipant?.publishData(
      utf8.encode('start_call'),
      reliable: true,
    );

    _startPublishing();
  }

  Future<void> _startPublishing() async {
    final localVideo = await LocalVideoTrack.createCameraTrack();
    final localAudio = await LocalAudioTrack.create();

    final videoPub = await _room!.localParticipant?.publishVideoTrack(
      localVideo,
    );
    final audioPub = await _room!.localParticipant?.publishAudioTrack(
      localAudio,
    );

    setState(() {
      _videoPublication = videoPub;
      _audioPublication = audioPub;
      _localVideoTrack = localVideo;
      _localAudioTrack = localAudio;
      _callStarted = true;
      _isAudioMuted = false;
      _isVideoMuted = false;
    });

    print('Published local video and audio tracks');
  }

  void _toggleAudio() async {
    if (_audioPublication == null) return;
    if (_isAudioMuted) {
      await _audioPublication!.unmute();
    } else {
      await _audioPublication!.mute();
    }
    setState(() => _isAudioMuted = !_isAudioMuted);
  }

  void _toggleVideo() async {
    if (_videoPublication == null) return;
    if (_isVideoMuted) {
      await _videoPublication!.unmute();
    } else {
      await _videoPublication!.mute();
    }
    setState(() => _isVideoMuted = !_isVideoMuted);
  }

  @override
  void dispose() {
    _room?.dispose();
    _localVideoTrack?.dispose();
    _localAudioTrack?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    if (screenWidth > 600) crossAxisCount = 2;
    if (screenWidth > 900) crossAxisCount = 3;

    final Map<String, VideoTrack> allVideoTracks = {
      if (_localVideoTrack != null && !_isVideoMuted)
        widget.userIdentity: _localVideoTrack!,
      ..._remoteVideoTracks,
    };

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFBBDEFB), Color(0xFFD1C4E9)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                'Meeting: ${1}', // Replace with widget.roomId if needed
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.videocam, color: Colors.white, size: 50),
                  ),
                ),
              ),
              floating: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👥 Participants section
                    Text(
                      'Participants (${_participantNames.length}):',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: _participantNames.map((name) {
                        final isYou = name == widget.userIdentity;
                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: isYou
                                ? Colors.purple[100]
                                : Colors.grey[300],
                            child: Icon(
                              isYou ? Icons.person : Icons.group,
                              color: isYou ? Colors.purple : Colors.grey[700],
                              size: 18,
                            ),
                          ),
                          label: Text(
                            isYou ? '$name (You)' : name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (widget.isHost && !_callStarted)
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Start Call"),
                          onPressed: _sendStartCall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 🎥 Video Grid
            SliverFillRemaining(
              child: allVideoTracks.isEmpty
                  ? const Center(
                      child: Text(
                        'No video yet. Waiting for participants to join...',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 16 / 9,
                      ),
                      itemCount: allVideoTracks.length,
                      itemBuilder: (context, index) {
                        final identity = allVideoTracks.keys.elementAt(index);
                        final track = allVideoTracks.values.elementAt(index);
                        final isYou = identity == widget.userIdentity;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isYou ? Colors.purple : Colors.blueGrey,
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            children: [
                              VideoTrackRenderer(track),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isYou ? 'You' : identity,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Move the comma here to separate the body and bottomNavigationBar
      bottomNavigationBar: _callStarted
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Mic Toggle
                  _buildControlIconButton(
                    icon: _isAudioMuted ? Icons.mic_off : Icons.mic,
                    tooltip: _isAudioMuted ? 'Unmute' : 'Mute',
                    color: _isAudioMuted ? Colors.red : Colors.green,
                    onTap: _toggleAudio,
                  ),

                  // Video Toggle
                  _buildControlIconButton(
                    icon: _isVideoMuted ? Icons.videocam_off : Icons.videocam,
                    tooltip: _isVideoMuted ? 'Turn Video On' : 'Turn Video Off',
                    color: _isVideoMuted ? Colors.red : Colors.green,
                    onTap: _toggleVideo,
                  ),

                  // (Optional) Screen Share – for Web only
                  if (kIsWeb)
                    _buildControlIconButton(
                      icon: _screenShareTrack != null
                          ? Icons.stop_screen_share
                          : Icons.screen_share,
                      tooltip: _screenShareTrack != null
                          ? 'Stop Screen Share'
                          : 'Share Screen',
                      color: Colors.orange,
                      onTap: _screenShareTrack != null
                          ? _stopScreenShare
                          : _startScreenShare,
                    ),

                  // End Call
                  _buildControlIconButton(
                    icon: Icons.call_end,
                    tooltip: 'End Call',
                    color: Colors.red,
                    onTap: () {
                      _room?.disconnect();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildControlIconButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(tooltip, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
