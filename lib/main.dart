import 'package:flutter/material.dart';
import 'create_room_page.dart'; // <--- import this
import 'join_meeting_page.dart'; // <--- import at top
import 'teacher_list_page.dart';

const String serverUrl =
    'http://192.168.1.23:3000'; // replace with your server URL

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiveKit Teams Flow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TeacherListPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LiveKit Teams Flow')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Create Room (Host)'),
              onPressed: () {
                // For now, just print — we will add navigation later
                print('Create Room pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateRoomPage()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Join Meeting (Participant)'),
              onPressed: () {
                // For now, just print — we will add navigation later
                print('Join Meeting pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JoinMeetingPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
