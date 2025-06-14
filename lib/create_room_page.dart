import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'waiting_room_page.dart';

const String serverUrl =
    'http://192.168.1.23:3000'; // replace with your server URL

class CreateRoomPage extends StatefulWidget {
  @override
  _CreateRoomPageState createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  String? roomId;
  String? password;
  bool _loading = true;

  Future<void> _createRoom() async {
    try {
      final response = await http.get(Uri.parse('$serverUrl/api/create-room'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("room_id ==>> " + data['room_id']);
        print("room_password ==>>" + data['room_password']);
        setState(() {
          roomId = data['room_id'];
          password = data['room_password'];
          _loading = false;
        });
      } else {
        throw Exception('Failed to create room');
      }
    } catch (e) {
      print('Error creating room: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _createRoom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Room')),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : roomId == null
            ? Text('Failed to create room.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Room ID: $roomId'),
                  Text('Password: $password'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Join as Host'),
                    onPressed: () {
                      print('Join as Host pressed (room_id: $roomId)');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingRoomPage(
                            roomId: roomId!,
                            password: password!,
                            userIdentity: 'host',
                            isHost: true,
                          ),
                        ),
                      );
                      // In next step we will navigate to WaitingRoomPage
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
