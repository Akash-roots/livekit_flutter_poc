import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String studentName;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.studentName,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late WebSocketChannel _channel;
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  String? userId;

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  Future<void> connectWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    userId = prefs.getString('user_id');

    final wsUrl = dotenv.env['WS_URL']; // Example: ws://localhost:3000
    _channel = WebSocketChannel.connect(Uri.parse('$wsUrl?token=$token'));

    _channel.stream.listen((data) {
      final message = json.decode(data);
      setState(() {
        _messages.add(message);
      });
    });
  }

  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final msg = {"roomId": widget.roomId, "text": text, "senderId": userId};

    _channel.sink.add(jsonEncode(msg));
    setState(() {
      _messages.add({"senderId": userId, "text": text});
      _controller.clear();
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.studentName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == userId;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(message['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
