import 'package:flutter/material.dart';
import 'screens/create_room_page.dart';
import 'screens/join_meeting_page.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String serverUrl =
    'http://192.168.1.23:3000'; // replace with your server URL

void main() async {
  await dotenv.load(fileName: ".env"); // Ensure this is awaited
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roots Edtech',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
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
