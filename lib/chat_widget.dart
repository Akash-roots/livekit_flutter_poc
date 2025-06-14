// import 'package:flutter/material.dart';
// import 'chat_message.dart';
// import 'chat_service.dart';

// class ChatWidget extends StatefulWidget {
//   final ChatService chatService;
//   const ChatWidget({super.key, required this.chatService});

//   @override
//   State<ChatWidget> createState() => _ChatWidgetState();
// }

// class _ChatWidgetState extends State<ChatWidget> {
//   final List<ChatMessage> _messages = [];
//   final TextEditingController _controller = TextEditingController();

//   void _onMessage(ChatMessage msg) {
//     setState(() {
//       _messages.add(msg);
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     widget.chatService.onMessageReceived = _onMessage;
//   }

//   void _sendMessage() {
//     final text = _controller.text.trim();
//     if (text.isNotEmpty) {
//       widget.chatService.sendMessage(text);
//       _controller.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView.builder(
//             itemCount: _messages.length,
//             itemBuilder: (_, index) {
//               final msg = _messages[index];
//               return ListTile(
//                 title: Text(msg.sender),
//                 subtitle: Text(msg.message),
//                 trailing: Text(
//                   '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
//                   style: TextStyle(fontSize: 10),
//                 ),
//               );
//             },
//           ),
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 decoration: InputDecoration(hintText: 'Type message...'),
//               ),
//             ),
//             IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
//           ],
//         ),
//       ],
//     );
//   }
// }
