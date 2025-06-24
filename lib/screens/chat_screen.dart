import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> teacher;
  final String? studentId;

  const ChatScreen({super.key, required this.teacher, required this.studentId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late WebSocketChannel _channel;
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final serverUrl = dotenv.env['SERVER_URL'];
  final wsUrl = dotenv.env['WS_URL'];
  String? roomId;
  String? token;

  @override
  void initState() {
    super.initState();
    _getRoomId();
  }

  Future<void> _getRoomId() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please log in again.'),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/room/chat-room'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user2Id': widget.teacher['user_id']}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          roomId = json['roomId'];
        });
        _connectWebSocket();
      } else {
        print("Failed to get room: ${response.body}");
      }
    } catch (e) {
      print("Room ID error: $e");
    }
  }

  void _connectWebSocket() {
    final wsUrl = 'ws://192.168.1.30:3000/?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen((data) {
      final decoded = jsonDecode(data);
      setState(() {
        _messages.add(decoded);
      });
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || roomId == null) return;

    final message = {
      'toUserId': widget.teacher['user_id'],
      'text': text,
      'roomId': roomId,
    };

    _channel.sink.add(jsonEncode(message));

    setState(() {
      _messages.add({'from': widget.studentId, 'text': text});
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacher['full_name'] ?? 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['from'] == widget.studentId;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
