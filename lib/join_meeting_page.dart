import 'package:flutter/material.dart';
import 'waiting_room_page.dart';

class JoinMeetingPage extends StatefulWidget {
  @override
  _JoinMeetingPageState createState() => _JoinMeetingPageState();
}

class _JoinMeetingPageState extends State<JoinMeetingPage> {
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _identityController = TextEditingController(
    text: 'user-xxx',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Join Meeting')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _roomIdController,
              decoration: InputDecoration(labelText: 'Room ID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Room Password'),
            ),
            TextField(
              controller: _identityController,
              decoration: InputDecoration(labelText: 'Your Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Join'),
              onPressed: () {
                print(
                  'Join pressed: Room=${_roomIdController.text}, Password=${_passwordController.text}, Identity=${_identityController.text}',
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WaitingRoomPage(
                      roomId: _roomIdController.text,
                      password: _passwordController.text,
                      userIdentity: _identityController.text,
                      isHost: false,
                    ),
                  ),
                );
                // Next step → we will navigate to WaitingRoomPage
              },
            ),
          ],
        ),
      ),
    );
  }
}
