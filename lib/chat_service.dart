// import 'dart:convert';
// import 'package:livekit_client/livekit_client.dart';
// import 'package:livekit_flutter_poc/chat_message.dart' as mychat;

// class ChatService {
//   final Room room;
//   final String selfIdentity;
//   Function(ChatMessage) onMessageReceived;

//   ChatService({
//     required this.room,
//     required this.selfIdentity,
//     required this.onMessageReceived,
//   }) {
//     room.events.listen((event) {
//       if (event is DataReceivedEvent) {
//         final decoded = utf8.decode(event.data);
//         try {
//           final json = jsonDecode(decoded);
//           final chat = ChatMessage.fromJson(json);
//           onMessageReceived(chat);
//         } catch (e) {
//           print('Invalid chat message format: $decoded');
//         }
//       }
//     });
//   }

//   void sendMessage(String text) {
//     final message = ChatMessage(
//       sender: selfIdentity,
//       message: text,
//       timestamp: DateTime.now(),
//     );
//     final encoded = jsonEncode(message.toJson());
//     room.localParticipant?.publishData(utf8.encode(encoded), reliable: true);
//   }
// }
