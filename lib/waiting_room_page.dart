import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:screen_share_plugin/screen_share_plugin.dart';

const String serverUrl = 'http://192.168.1.23:3000';
const String livekitUrl = 'ws://192.168.1.23:7880';

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

    await room.connect(livekitUrl, token);

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
    final localVideoTrack = await LocalVideoTrack.createCameraTrack();
    final localAudioTrack = await LocalAudioTrack.create();

    await _room?.localParticipant?.publishVideoTrack(localVideoTrack);
    await _room?.localParticipant?.publishAudioTrack(localAudioTrack);

    setState(() {
      _localVideoTrack = localVideoTrack;
      _localAudioTrack = localAudioTrack;
      _callStarted = true;
    });
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
    return Scaffold(
      appBar: AppBar(title: Text('Waiting Room')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Waiting in Room: ${widget.roomId}'),
            SizedBox(height: 10),
            Text('Participants (${_participantNames.length}):'),
            SizedBox(height: 10),
            ..._participantNames.map((name) => Text('- $name')).toList(),
            SizedBox(height: 20),
            if (widget.isHost && !_callStarted)
              ElevatedButton(
                child: Text('Start Call'),
                onPressed: _sendStartCall,
              ),
            SizedBox(height: 10),

            // Video display area
            Expanded(
              child: ListView(
                children: [
                  if (_localVideoTrack != null)
                    Container(
                      margin: const EdgeInsets.all(8),
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: VideoTrackRenderer(_localVideoTrack!),
                    ),
                  ..._remoteVideoTracks.entries.map(
                    (entry) => Container(
                      margin: const EdgeInsets.all(8),
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.greenAccent),
                      ),
                      child: VideoTrackRenderer(entry.value),
                    ),
                  ),
                ],
              ),
            ),

            // // Screen sharing buttons (visible only after call starts)
            // if (_callStarted)
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       ElevatedButton(
            //         onPressed: () async {
            //           await ScreenSharePlugin.startScreenShare();
            //         },
            //         child: Text("Start Screen Share"),
            //       ),
            //       ElevatedButton(
            //         onPressed: () async {
            //           await ScreenSharePlugin.stopScreenShare();
            //         },
            //         child: Text("Stop Screen Share"),
            //       ),
            //     ],
            //   ),
            if (_callStarted && kIsWeb)
              ElevatedButton(
                onPressed: _startScreenShare,
                child: Text('Start Screen Share'),
              ),
            if (_screenShareTrack != null)
              ElevatedButton(
                onPressed: _stopScreenShare,
                child: Text('Stop Screen Share'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.call_end),
        backgroundColor: Colors.red,
        onPressed: () {
          _room?.disconnect();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }
}
