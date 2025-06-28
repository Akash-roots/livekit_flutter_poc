import 'package:flutter/material.dart';
import 'chat_room_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TeacherMessagesPage extends StatefulWidget {
  const TeacherMessagesPage({super.key});

  @override
  State<TeacherMessagesPage> createState() => _TeacherMessagesPageState();
}

class _TeacherMessagesPageState extends State<TeacherMessagesPage> {
  List<dynamic> _conversations = [];
  bool _loading = true;
  String? _error;
  int? _userId;

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    print('Fetching conversations...');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    _userId = int.tryParse(prefs.getString('userId') ?? '') ?? 0;
    final baseUrl = dotenv.env['SERVER_URL'];

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/messages/recent-chats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          _conversations = json.decode(res.body);
          print('Conversations fetched: ${_conversations}');
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load messages.";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_conversations.isEmpty) {
      return const Center(child: Text('No conversations found.'));
    }

    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final convo = _conversations[index];

        final senderId = convo['sender']['id'];
        final receiverId = convo['receiver']['id'];
        final currentUserId = _userId ?? 0;
        final isCurrentUserSender = senderId == currentUserId;

        final studentId = isCurrentUserSender ? receiverId : senderId;
        final studentName = isCurrentUserSender
            ? convo['receiver']['full_name']
            : convo['sender']['full_name'];

        return ListTile(
          title: Text(convo['student_name'] ?? 'Student'),
          subtitle: Text(convo['last_message'] ?? ''),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomPage(
                  roomId: convo['room_id'],
                  studentName: studentName ?? 'Student',
                  studentId: studentId ?? 0,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
