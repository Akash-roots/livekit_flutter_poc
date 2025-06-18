import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatSocketService {
  final String userId;
  final WebSocketChannel channel;
  final serverUrl = dotenv.env['SERVER_URL'];

  ChatSocketService._(this.userId, this.channel);

  Future<ChatSocketService> connect(String userId) async {
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://$serverUrl/chat?userId=$userId'),
    );
    return ChatSocketService._(userId, channel);
  }

  void sendMessage(String toUserId, String text) {
    final payload = jsonEncode({'toUserId': toUserId, 'text': text});
    channel.sink.add(payload);
  }

  Stream<Map<String, dynamic>> get messages =>
      channel.stream.map((data) => jsonDecode(data));

  void disconnect() {
    channel.sink.close();
  }
}
