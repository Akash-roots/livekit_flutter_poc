import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart'
    as lk; // Alias livekit_client
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For web-specific checks
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  lk.Room? _room;
  // Use a map to store participant identities and their connection status/details
  final Map<String, lk.Participant> _participants = {}; // Use aliased type
  lk.LocalVideoTrack? _screenShareTrack;
  lk.LocalTrackPublication? _screenSharePublication;

  lk.LocalVideoTrack? _localVideoTrack;
  lk.LocalAudioTrack? _localAudioTrack;
  bool _callStarted =
      false; // Tracks if the call has officially started (host initiated)
  String? _connectionStatus; // To display connection status

  // New state variables for UI control of mute/video enable
  bool _isAudioMuted = false;
  bool _isVideoMuted = false;

  final Map<String, lk.VideoTrack> _remoteVideoTracks =
      {}; // Stores remote video tracks by participant identity

  @override
  void initState() {
    super.initState();
    _start(); // Initiate permissions and connection
  }

  // --- LiveKit Connection and Event Handling ---

  Future<void> _start() async {
    setState(() {
      _connectionStatus = 'Requesting permissions...';
    });
    await _requestPermissions();
    setState(() {
      _connectionStatus = 'Connecting to meeting...';
    });
    await _connectToRoom();
  }

  // Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await [Permission.camera, Permission.microphone].request();
    }
  }

  // Fetch LiveKit token from your backend server
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
      throw Exception('Failed to fetch token: ${response.statusCode}');
    }
  }

  // Connect to the LiveKit room
  Future<void> _connectToRoom() async {
    try {
      final token = await _fetchToken();
      final room = lk.Room(); // Use aliased constructor

      // Listen to various room events
      room.events.listen(_onRoomEvent);

      await room.connect(livekitUrl!, token);
      print('Connected to LiveKit room: ${room.name}');

      setState(() {
        _room = room;
        _participants[room.localParticipant!.identity] = room.localParticipant!;
        _updateParticipantList(room);
        // Add existing remote participants and their video tracks
        for (var remoteParticipant in room.remoteParticipants.values) {
          _participants[remoteParticipant.identity] = remoteParticipant;
          for (var pub in remoteParticipant.videoTrackPublications) {
            if (pub.subscribed &&
                pub.track != null &&
                pub.track is lk.VideoTrack) {
              // Use aliased type
              _remoteVideoTracks[remoteParticipant.identity] =
                  pub.track as lk.VideoTrack; // Use aliased type
            }
          }
        }
        _connectionStatus = 'Connected';
      });

      // If host, start publishing immediately if not already done by _sendStartCall
      if (widget.isHost && !_callStarted) {
        _startPublishing();
        // Optionally send a start call signal immediately if host
        // _sendStartCall(); // This could be automatic for host upon connection
      }
    } catch (e) {
      print('Error connecting to room: $e');
      setState(() {
        _connectionStatus = 'Failed to connect. $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to the meeting: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // Optionally, pop back to the previous screen
      Navigator.pop(context);
    }
  }

  // Handle various room events
  void _onRoomEvent(lk.RoomEvent event) {
    // Use aliased type
    setState(() {
      if (event is lk.ParticipantConnectedEvent) {
        // Use aliased type
        print('Participant connected: ${event.participant.identity}');
        _participants[event.participant.identity] = event.participant;
        _updateParticipantList(_room!);
      } else if (event is lk.ParticipantDisconnectedEvent) {
        // Use aliased type
        print('Participant disconnected: ${event.participant.identity}');
        _participants.remove(event.participant.identity);
        _remoteVideoTracks.remove(event.participant.identity);
        _updateParticipantList(_room!);
      } else if (event is lk.DataReceivedEvent) {
        // Use aliased type
        final msg = utf8.decode(event.data);
        print('Received DataTrack message: $msg');
        if (msg == 'start_call' && !_callStarted) {
          _startPublishing(); // Start publishing when host initiates call
        }
      } else if (event is lk.TrackSubscribedEvent) {
        // Use aliased type
        if (event.track is lk.VideoTrack) {
          // Use aliased type
          print('Remote video track subscribed: ${event.participant.identity}');
          _remoteVideoTracks[event.participant.identity] =
              event.track as lk.VideoTrack; // Use aliased type
        }
      } else if (event is lk.TrackUnsubscribedEvent) {
        // Use aliased type
        if (event.track is lk.VideoTrack) {
          // Use aliased type
          print(
            'Remote video track unsubscribed: ${event.participant.identity}',
          );
          _remoteVideoTracks.remove(event.participant.identity);
        }
      } else if (event is lk.LocalTrackPublishedEvent) {
        // Use aliased type
        print('Local track published: ${event.publication.sid}');
      } else if (event is lk.LocalTrackUnpublishedEvent) {
        // Use aliased type
        print('Local track unpublished: ${event.publication.sid}');
      }
    });
  }

  // Update the list of participants (used for displaying names)
  void _updateParticipantList(lk.Room room) {
    // Use aliased type
    List<String> names = [];
    if (room.localParticipant != null) {
      names.add(
        room.localParticipant!.identity + ' (You)',
      ); // Identify local user
    }
    room.remoteParticipants.values.forEach((p) {
      names.add(p.identity);
    });
    print('Current participants: ${names.join(', ')}');
  }

  // --- Screen Sharing Logic ---

  Future<void> _startScreenShare() async {
    try {
      final screenTrack =
          await lk.LocalVideoTrack.createScreenShareTrack(); // Use aliased type
      if (screenTrack != null) {
        final pub = await _room?.localParticipant?.publishVideoTrack(
          screenTrack,
        );
        setState(() {
          _screenShareTrack = screenTrack;
          _screenSharePublication = pub; // Store the publication
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen sharing started!')),
        );
      }
    } catch (e) {
      print('Failed to start screen share: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start screen share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopScreenShare() async {
    // Corrected: Call unpublishTrack on _room?.localParticipant? with the publication object
    // if (_screenSharePublication != null) {
    //   await _room?.localParticipant?.unpublishTrack(_screenSharePublication!);
    // }

    if (_screenShareTrack != null) {
      await _screenShareTrack!.stop(); // Stop the track resources
    }

    setState(() {
      _screenShareTrack = null;
      _screenSharePublication = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Screen sharing stopped!')));
  }

  // --- Call Control Logic ---

  // Host sends a data message to start the call for all participants
  void _sendStartCall() {
    _room?.localParticipant?.publishData(
      utf8.encode('start_call'),
      reliable: true,
    );
    _startPublishing(); // Also start publishing for the host
  }

  // Start publishing local camera and microphone tracks
  Future<void> _startPublishing() async {
    print('Attempting to start publishing video and audio...');
    bool videoPublished = false;
    bool audioPublished = false;

    try {
      // Try creating and publishing video track
      try {
        final localVideoTrack = await lk.LocalVideoTrack.createCameraTrack();
        if (localVideoTrack != null) {
          print('Local video track created successfully.');
          await _room?.localParticipant?.publishVideoTrack(localVideoTrack);
          setState(() {
            _localVideoTrack = localVideoTrack;
            _isVideoMuted = false; // Set to false when track is active
            videoPublished = true;
          });
          print('Local video track published.');
        } else {
          print('Failed to create local video track (returned null).');
          // Optionally show a more specific error for video track creation failure
        }
      } catch (videoError) {
        print('Error creating or publishing video track: $videoError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start video: $videoError'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Try creating and publishing audio track
      try {
        final localAudioTrack = await lk.LocalAudioTrack.create();
        if (localAudioTrack != null) {
          print('Local audio track created successfully.');
          await _room?.localParticipant?.publishAudioTrack(localAudioTrack);
          setState(() {
            _localAudioTrack = localAudioTrack;
            _isAudioMuted = false; // Set to false when track is active
            audioPublished = true;
          });
          print('Local audio track published.');
        } else {
          print('Failed to create local audio track (returned null).');
          // Optionally show a more specific error for audio track creation failure
        }
      } catch (audioError) {
        print('Error creating or publishing audio track: $audioError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start audio: $audioError'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (videoPublished || audioPublished) {
        setState(() {
          _callStarted = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call started! Publishing video and audio.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to start call. No video or audio tracks could be published.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('General error during publishing initiation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start call. Check permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Mute/unmute local audio
  void _toggleAudioMute() async {
    if (_localAudioTrack != null) {
      setState(() {
        _isAudioMuted = !_isAudioMuted; // Toggle the UI state variable
      });

      if (_isAudioMuted) {
        // If _isAudioMuted is now true, disable the track
        await _localAudioTrack!.disable();
      } else {
        // If _isAudioMuted is now false, enable the track
        await _localAudioTrack!.enable();
      }
      print(
        'Audio track UI mute status after toggle: $_isAudioMuted',
      ); // Debug print based on UI state
    } else {
      print(
        'Attempted to toggle audio mute, but _localAudioTrack is null. Attempting to start audio...',
      );
      _startPublishing(); // Try to start publishing if track is null
    }
  }

  // Enable/disable local video
  void _toggleVideoEnable() async {
    if (_localVideoTrack != null) {
      setState(() {
        _isVideoMuted = !_isVideoMuted; // Toggle the UI state variable
      });

      if (_isVideoMuted) {
        // If _isVideoMuted is now true, disable the track
        await _localVideoTrack!.disable();
      } else {
        // If _isVideoMuted is now false, enable the track
        await _localVideoTrack!.enable();
      }
      print(
        'Video track UI mute status after toggle: $_isVideoMuted',
      ); // Debug print based on UI state
    } else {
      print(
        'Attempted to toggle video enable, but _localVideoTrack is null. Attempting to start video...',
      );
      _startPublishing(); // Attempt to start video if it's null
    }
  }

  @override
  void dispose() {
    // Dispose resources when the widget is removed
    _room?.disconnect();
    _localVideoTrack?.dispose();
    _localAudioTrack?.dispose();
    _screenShareTrack?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the number of columns for the video grid based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    if (screenWidth > 600) {
      crossAxisCount = 2;
    }
    if (screenWidth > 900) {
      crossAxisCount = 3;
    }

    // Combine local and remote video tracks for rendering
    final Map<String, lk.VideoTrack> allVideoTracks = {
      // Use aliased type
      // Only include local video if it's not null AND NOT muted (using _isVideoMuted)
      if (_localVideoTrack != null && !_isVideoMuted)
        widget.userIdentity: _localVideoTrack!,
      ..._remoteVideoTracks,
    };

    return Scaffold(
      // Consistent gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFBBDEFB), // Light blue
              Color(0xFFD1C4E9), // Light purple
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                'Meeting: ${widget.roomId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Make app bar transparent
              elevation: 0, // No shadow
              expandedHeight: 120, // Taller header
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                    child: Icon(
                      Icons.videocam, // Relevant icon for meeting in progress
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
              floating: true,
              pinned: false,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meeting ID: ${widget.roomId}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Identity: ${widget.userIdentity}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(
                                _room?.connectionState ==
                                        lk.ConnectionState.connected
                                    ? Icons.check_circle_rounded
                                    : Icons.wifi_off_rounded,
                                color:
                                    _room?.connectionState ==
                                        lk.ConnectionState.connected
                                    ? Colors.green
                                    : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _connectionStatus ?? 'Connecting...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      _room?.connectionState ==
                                          lk.ConnectionState.connected
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Participants count and list
                    Text(
                      'Participants (${_participants.length}):',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display participants using a Wrap for flexible layout with styled chips
                    Wrap(
                      spacing: 10.0, // horizontal space between adjacent chips
                      runSpacing: 8.0, // vertical space between lines
                      children: _participants.values.map((pRaw) {
                        final p = pRaw as lk.Participant;
                        final isLocal = p.identity == widget.userIdentity;
                        // Use the UI state for local user's mute status, LiveKit's for remote
                        final currentIsMuted = isLocal
                            ? _isAudioMuted
                            : p.isMuted;

                        return Chip(
                          avatar: CircleAvatar(
                            backgroundColor: isLocal
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2)
                                : Colors.blueGrey.shade100,
                            child: Icon(
                              isLocal ? Icons.person : Icons.group,
                              color: isLocal
                                  ? Theme.of(context).primaryColor
                                  : Colors.blueGrey.shade700,
                              size: 18,
                            ),
                          ),
                          label: Text(
                            isLocal ? '${p.identity} (You)' : p.identity,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          backgroundColor: isLocal
                              ? Theme.of(context).primaryColor.withOpacity(0.05)
                              : Colors.blueGrey.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: isLocal
                                  ? Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.4)
                                  : Colors.blueGrey.shade200,
                            ),
                          ),
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          deleteIcon: Icon(
                            currentIsMuted ? Icons.mic_off : Icons.mic,
                            size: 18,
                            color: currentIsMuted
                                ? Colors.redAccent
                                : Colors.green,
                          ),
                          onDeleted: null, // Just for icon display
                          deleteButtonTooltipMessage: currentIsMuted
                              ? 'Muted'
                              : 'Unmuted',
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    // Host specific control to start the call
                    if (widget.isHost && !_callStarted)
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.play_circle_fill_outlined,
                            size: 28,
                          ),
                          label: const Text(
                            'Start Live Session',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: _sendStartCall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .purple
                                .shade600, // Distinct color for host action
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            shadowColor: Colors.purple.shade600.withOpacity(
                              0.4,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Video display area
            SliverFillRemaining(
              // Use SliverFillRemaining to let video grid take remaining space
              child: allVideoTracks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _callStarted
                                ? 'No active video feeds yet.\nWait for participants to join and publish video.'
                                : 'Session not started.\nHost needs to start the live session.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12.0, // Increased spacing
                        mainAxisSpacing: 12.0, // Increased spacing
                        childAspectRatio: 16 / 9, // Standard video aspect ratio
                      ),
                      itemCount: allVideoTracks.length,
                      itemBuilder: (context, index) {
                        final identity = allVideoTracks.keys.elementAt(index);
                        final videoTrack = allVideoTracks.values.elementAt(
                          index,
                        );
                        final isLocal = identity == widget.userIdentity;

                        return Container(
                          // Use Container with BoxDecoration for consistent styling
                          decoration: BoxDecoration(
                            color: Colors.black, // Dark background for video
                            borderRadius: BorderRadius.circular(
                              15,
                            ), // Rounded corners for video tiles
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(
                              color: isLocal
                                  ? Theme.of(context).primaryColor
                                  : Colors.blueGrey.shade400,
                              width:
                                  3, // More prominent border for active speaker/self
                            ),
                          ),
                          child: ClipRRect(
                            // Clip video to rounded corners
                            borderRadius: BorderRadius.circular(12.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                lk.VideoTrackRenderer(
                                  videoTrack,
                                ), // LiveKit video renderer
                                // Participant name overlay
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      isLocal
                                          ? 'You'
                                          : identity, // Show "You" for local video
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Call controls and screen sharing buttons
      bottomNavigationBar: _callStarted
          ? Container(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 20.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.95,
                ), // Slightly transparent white background
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ), // Rounded top corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -10), // Shadow at the top
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute/Unmute Audio Button
                  _buildControlIconButton(
                    icon: _isAudioMuted ? Icons.mic_off : Icons.mic,
                    color: _isAudioMuted
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                    tooltip: _isAudioMuted ? 'Unmute' : 'Mute',
                    onPressed: _toggleAudioMute,
                  ),
                  // Video On/Off Button
                  _buildControlIconButton(
                    icon: _isVideoMuted ? Icons.videocam_off : Icons.videocam,
                    color: _isVideoMuted
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                    tooltip: _isVideoMuted ? 'Turn Video On' : 'Turn Video Off',
                    onPressed: _toggleVideoEnable,
                  ),
                  // Screen Sharing Buttons (Web only)
                  if (kIsWeb)
                    _buildControlIconButton(
                      icon: _screenShareTrack != null
                          ? Icons.screen_share
                          : Icons.mobile_screen_share,
                      color: _screenShareTrack != null
                          ? Colors.orange.shade600
                          : Colors.blueGrey.shade600,
                      tooltip: _screenShareTrack != null
                          ? 'Stop Share'
                          : 'Share Screen',
                      onPressed: _screenShareTrack != null
                          ? _stopScreenShare
                          : _startScreenShare,
                    ),
                  // End Call Button
                  _buildControlIconButton(
                    icon: Icons.call_end,
                    color: Colors.red.shade700,
                    tooltip: 'End Call',
                    onPressed: () {
                      // Show a confirmation dialog before disconnecting
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              "End Meeting",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              "Are you sure you want to leave this meeting?",
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Dismiss dialog
                                },
                              ),
                              ElevatedButton(
                                child: const Text(
                                  "Leave",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  _room
                                      ?.disconnect(); // Disconnect from LiveKit room
                                  Navigator.of(context).pop(); // Dismiss dialog
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  ); // Pop to home screen
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )
          : null, // Hide bottom navigation bar if call not started
    );
  }

  // Helper widget for consistent control bar buttons (updated for unique UI)
  Widget _buildControlIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(
            30,
          ), // Rounded for FAB-like tap area
          child: Container(
            width: 55, // Fixed size
            height: 55, // Fixed size
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: Colors.white), // Larger icon
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tooltip,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
