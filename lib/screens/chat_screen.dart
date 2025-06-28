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
  final wsBaseUrl = dotenv.env['WS_URL'];
  String? roomId;
  String? token;
  String? userId;
  final Map<String, List<Map<String, dynamic>>> _groupedMessages = {};

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
        roomId = json['roomId'];

        await _loadChatHistory(); // Step 1: Load history
        _groupMessages(); // <-- ADD THIS LINE
        _connectWebSocket(); // Step 2: WebSocket
      } else {
        print("Failed to get room: ${response.body}");
      }
    } catch (e) {
      print("Room ID error: $e");
    }
  }

  Future<void> _loadChatHistory() async {
    if (roomId == null) return;

    try {
      final response = await http.get(
        Uri.parse('$serverUrl/messages/history/$roomId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _messages.addAll(
            data.map(
              (msg) => {
                'from': msg['sender_id'].toString(),
                'text': msg['message'],
                'created_at': msg['created_at'],
              },
            ),
          );
        });
      } else {
        print('Failed to load chat history: ${response.body}');
      }
    } catch (e) {
      print('Chat history error: $e');
    }
  }

  void _connectWebSocket() {
    final wsUrl = '$wsBaseUrl?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel.stream.listen((data) {
      final decoded = jsonDecode(data);
      setState(() {
        _messages.add(decoded);
        _groupMessages();
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
      'fromUserId': widget.studentId,
    };

    _channel.sink.add(jsonEncode(message));

    setState(() {
      _messages.add({
        'from': widget.studentId,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
      _controller.clear();
      _groupMessages();
    });
  }

  void _groupMessages() {
    _groupedMessages.clear();
    print(_messages);
    for (final msg in _messages) {
      final dt = DateTime.tryParse(msg['created_at'] ?? '')?.toLocal();
      if (dt == null) continue;
      final dateLabel = _getDateLabel(dt);
      _groupedMessages.putIfAbsent(dateLabel, () => []).add(msg);
    }
  }

  String _getDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dt.year, dt.month, dt.day);

    if (messageDay == today) return 'Today';
    if (messageDay == today.subtract(const Duration(days: 1)))
      return 'Yesterday';
    return '${messageDay.day}/${messageDay.month}/${messageDay.year}';
  }

  String _formatTime(String raw) {
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.teacher['full_name'] ?? 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: _groupedMessages.entries.expand((entry) {
                return [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(entry.key),
                    ),
                  ),
                  ...entry.value.map((msg) {
                    final isMe = msg['from'] == widget.studentId;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(msg['created_at']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ];
              }).toList(),
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
