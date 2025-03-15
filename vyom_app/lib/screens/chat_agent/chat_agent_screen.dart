import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool hasAttachment;
  final VoidCallback? onAttachmentTap;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.hasAttachment = false,
    this.onAttachmentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Define colors based on message sender
    final bubbleColor = isUser 
        ? theme.colorScheme.primary 
        : theme.colorScheme.secondary.withOpacity(0.3);
    final textColor = isUser 
        ? theme.colorScheme.onPrimary 
        : theme.colorScheme.onBackground;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            // Add a bit more design flair with different corner radii
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isUser ? 16 : 4),
              topRight: Radius.circular(isUser ? 4 : 16),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message content
              Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
              
              // Optional attachment
              if (hasAttachment)
                GestureDetector(
                  onTap: onAttachmentTap,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.attachment,
                          color: textColor.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'View Attachment',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Timestamp
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 10,
                  ),
                  textAlign: isUser ? TextAlign.right : TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to format the timestamp
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Normal chat screen for two users (no AI involved)
class ChatAgentScreen extends StatefulWidget {
  const ChatAgentScreen({Key? key}) : super(key: key);

  @override
  State<ChatAgentScreen> createState() => _ChatAgentScreenState();
}

class _ChatAgentScreenState extends State<ChatAgentScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _messageController.clear();
    
    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(
        message: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true; // Show the "other" user is typing
    });

    // Simulate processing time for response (a delay for a more "natural" feel)
    Future.delayed(const Duration(seconds: 1), () {
      final responseMessage = _getResponse(userMessage);
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          message: responseMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  // Dummy logic to generate a response from the other person (for the sake of this example)
  String _getResponse(String userMessage) {
    if (userMessage.toLowerCase().contains('hello')) {
      return 'Hi there! How are you doing today?';
    } else if (userMessage.toLowerCase().contains('how are you')) {
      return 'I’m doing great, thanks for asking! What’s up?';
    } else {
      return 'I didn’t quite catch that, can you say it again?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // Info button or dialog for chat
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length,
              reverse: false,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.message,
                  isUser: message.isUser,
                  timestamp: message.timestamp,
                  hasAttachment: message.hasAttachment,
                  onAttachmentTap: message.hasAttachment ? () {} : null,
                );
              },
            ),
          ),
          
          // "Other person is typing" indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'Other person is typing...',
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Attachment button (optional)
                IconButton(
                  icon: Icon(Icons.attach_file, color: theme.colorScheme.primary),
                  onPressed: () {
                    // Handle attachment
                  },
                ),
                
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.onBackground.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                
                // Send button
                IconButton(
                  icon: Icon(Icons.send, color: theme.colorScheme.primary),
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

// Data model for chat messages
class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool hasAttachment;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.hasAttachment = false,
  });
}
