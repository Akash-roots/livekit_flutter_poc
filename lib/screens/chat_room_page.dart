import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatRoomPage extends StatefulWidget {
  final String? roomId;
  final String? studentName;
  final int? studentId;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late WebSocketChannel _channel;
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  String? userId;
  Map<String, List<Map<String, dynamic>>> _grouped = {};

  @override
  void initState() {
    super.initState();
    fetchPrev().then((_) => _groupAndConnect());
  }

  Future<void> fetchPrev() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final base = dotenv.env['SERVER_URL'];

    if (widget.roomId == null || token == null) return;

    final resp = await http.get(
      Uri.parse('$base/messages/history/${widget.roomId}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      final List data = json.decode(resp.body);
      _messages = data
          .map(
            (m) => {
              'senderId': m['sender_id'],
              'text': m['message'],
              'created_at': m['created_at'],
            },
          )
          .toList();
    }
  }

  void _groupAndConnect() async {
    // group
    _grouped.clear();
    for (var m in _messages) {
      final dt = DateTime.parse(m['created_at']).toLocal();
      final key = _labelFor(dt);
      (_grouped[key] ??= []).add(m);
    }
    setState(() {});

    // connect WS
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    userId = prefs.getString('userId');

    if (widget.roomId == null || token == null || userId == null) return;

    final wsUrl = dotenv.env['WS_URL']!; // e.g. ws://192.168.1.30:3000
    _channel = WebSocketChannel.connect(Uri.parse('$wsUrl?token=$token'));
    _channel.stream.listen((data) {
      final m = json.decode(data);
      setState(() {
        _messages.add(m);
        _groupAndConnect();
      });
    });
  }

  String _labelFor(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    final t = DateTime.now();
    final td = DateTime(t.year, t.month, t.day);
    if (d == td) return 'Today';
    if (d == td.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${d.day}/${d.month}/${d.year}';
  }

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isEmpty || widget.roomId == null || userId == null) return;

    final m = {
      "roomId": widget.roomId,
      "text": txt,
      "fromUserId": userId!,
      "toUserId": widget.studentId,
    };
    _channel.sink.add(json.encode(m));

    setState(() {
      _messages.add({
        "senderId": userId,
        "text": txt,
        "created_at": DateTime.now().toIso8601String(),
      });
      _groupAndConnect();
      _controller.clear();
    });
  }

  String _fmt(String raw) {
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _onAddToClass() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final base = dotenv.env['SERVER_URL'];
    if (token == null) return;

    List classes = [];
    final res = await http.get(
      Uri.parse('$base/classes/my-classes'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      classes = json.decode(res.body);
    }

    showModalBottomSheet(
      context: context,
      builder: (_) {
        String? selId;
        final txtCtl = TextEditingController();
        return StatefulBuilder(
          builder: (c, st) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Add to Class', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    items: classes
                        .map(
                          (cls) => DropdownMenuItem(
                            value: cls['id'].toString(),
                            child: Text(cls['name']),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => st(() => selId = v),
                    hint: const Text('Select existing class'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: txtCtl,
                    decoration: const InputDecoration(
                      labelText: 'Or create new class',
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      String? cid = selId;
                      if (cid == null && txtCtl.text.trim().isNotEmpty) {
                        final cr = await http.post(
                          Uri.parse('$base/classes/create'),
                          headers: {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          },
                          body: json.encode({'name': txtCtl.text.trim()}),
                        );
                        if (cr.statusCode == 200) {
                          cid = json.decode(cr.body)['id'].toString();
                        }
                      }
                      if (cid != null) {
                        await http.post(
                          Uri.parse('$base/classes/$cid/add-student'),
                          headers: {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          },
                          body: json.encode({'studentId': widget.studentId}),
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.studentName}'),
        actions: [
          PopupMenuButton(
            onSelected: (_) => _onAddToClass(),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'add', child: Text('Add to Class')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: _grouped.entries.map((e) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                        child: Text(e.key),
                      ),
                    ),
                    ...e.value.map((m) {
                      final isMe =
                          m['senderId'].toString() == userId.toString();
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['text'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _fmt(m['created_at']),
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
                  ],
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type message…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
