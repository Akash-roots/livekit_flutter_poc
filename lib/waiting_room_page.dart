import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

const String serverUrl = 'http://10.10.1.23:3000';
const String livekitUrl = 'ws://10.10.1.13:7880';

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

  LocalVideoTrack? _localVideoTrack; // NEW
  bool _callStarted = false; // NEW

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
    }
  }

  void _updateParticipantList(Room room) {
    List<String> names = [];

    // Add local participant first:
    if (room.localParticipant != null) {
      names.add(room.localParticipant!.identity);
    }

    // Add remote participants:
    room.remoteParticipants.values.forEach((p) {
      names.add(p.identity);
    });

    setState(() {
      _participantNames = names;
    });

    print('Current participants: $_participantNames');
  }

  // NEW → Host sends "start_call" + starts own video
  void _sendStartCall() {
    _room?.localParticipant?.publishData(
      utf8.encode('start_call'),
      reliable: true,
    );

    _startPublishing();
  }

  // NEW → Publish local video track
  Future<void> _startPublishing() async {
    final localVideoTrack = await LocalVideoTrack.createCameraTrack();

    await _room?.localParticipant?.publishVideoTrack(localVideoTrack);

    setState(() {
      _localVideoTrack = localVideoTrack;
      _callStarted = true;
    });
  }

  @override
  void dispose() {
    _room?.dispose();
    _localVideoTrack?.dispose(); // cleanup local video track
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
            if (_localVideoTrack != null)
              Container(
                margin: const EdgeInsets.all(8),
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: VideoTrackRenderer(_localVideoTrack!),
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
