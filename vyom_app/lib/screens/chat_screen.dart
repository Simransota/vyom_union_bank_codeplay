// import 'package:flutter/material.dart';
// import '../widgets/chat_message.dart';
// import '../widgets/chat_input.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<ChatMessage> _messages = [];

//   void _handleSend() {
//     final String text = _controller.text.trim();
//     if (text.isNotEmpty) {
//       setState(() {
//         _messages.add(ChatMessage(
//           text: text,
//           isUser: true,
//           hasAvatar: false,
//         ));
//         _controller.clear();
//         _handleResponse(text);
//       });
//     }
//   }

//   void _handleResponse(String query) {
//     String response;
//     if (query.toLowerCase().contains('loan')) {
//       response = 'For loan queries, please visit our loan section or contact our support team.';
//     } else if (query.toLowerCase().contains('interest rate')) {
//       response = 'The current interest rate for home loans is 6.5%.';
//     } else if (query.toLowerCase().contains('emi')) {
//       response = 'You can use our EMI calculator to estimate your monthly payments.';
//     } else {
//       response = 'I am sorry, I did not understand your query. Please provide more details.';
//     }

//     setState(() {
//       _messages.add(ChatMessage(
//         text: response,
//         isUser: false,
//         hasAvatar: true,
//       ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               child: const Icon(
//                 Icons.chat_bubble_outline,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Chatterbox AI',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_horiz, color: Colors.black),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return _messages[index];
//               },
//             ),
//           ),
//           ChatInput(
//             controller: _controller,
//             onSend: _handleSend,
//           ),
//         ],
//       ),
//     );
//   }
// }