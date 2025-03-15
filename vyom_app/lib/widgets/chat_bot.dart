import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:vyom/screens/voice_asstance/voice_assistance.dart';

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

// Additionally, here's a ChatScreen to showcase how to use the ChatBubble widget
class ChatScreen extends StatefulWidget {
  final GoogleTranslator? translator;
  final String currentLanguage;

  const ChatScreen({
    Key? key,
    this.translator,
    this.currentLanguage = 'en',
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add a welcome message from the assistant
    _addBotMessage("Hello! I'm your Vyom AI Assistant. How can I help you with your finances today?");
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<String> _translateText(String text) async {
    if (widget.translator == null || widget.currentLanguage == 'en') {
      return text;
    } else {
      try {
        var translation = await widget.translator!.translate(
          text, 
          from: 'en', 
          to: widget.currentLanguage
        );
        return translation.text;
      } catch (e) {
        print('Translation error: $e');
        return text; // Fallback to English if translation fails
      }
    }
  }

  void _sendMessage() async {
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
      _isTyping = true; // Show the bot is typing
    });

    // Simulate processing time (would be replaced with actual API call)
    await Future.delayed(const Duration(seconds: 1));

    // Get bot response based on user input
    final botResponse = await _getBotResponse(userMessage);

    // Add bot message to chat
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        message: botResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  Future<String> _getBotResponse(String message) async {
    // This is where you would integrate with your actual AI service
    // For now, we'll use some simple predefined responses
    
    final lowercaseMessage = message.toLowerCase();
    
    if (lowercaseMessage.contains('loan') || lowercaseMessage.contains('credit')) {
      return await _translateText("Based on your current CIBIL score of 750, you qualify for personal loans with interest rates starting at 9.5%. Would you like me to show you some offers?");
    } else if (lowercaseMessage.contains('bill') || lowercaseMessage.contains('payment')) {
      return await _translateText("You have an upcoming electricity bill payment due on the 25th. Would you like me to set up a reminder or help you schedule the payment?");
    } else if (lowercaseMessage.contains('save') || lowercaseMessage.contains('saving')) {
      return await _translateText("To reach your goal of saving ₹10,000 this quarter, I recommend setting aside ₹770 weekly. Would you like help setting up an automatic transfer?");
    } else if (lowercaseMessage.contains('security') || lowercaseMessage.contains('password')) {
      return await _translateText("It's been 3 months since your last password update. For enhanced security, I recommend changing it. Would you like me to guide you through the process?");
    } else {
      return await _translateText("Thank you for your message. How else can I assist you with your financial needs today?");
    }
  }

  void _addBotMessage(String message) async {
    final translatedMessage = await _translateText(message);
    setState(() {
      _messages.add(ChatMessage(
        message: translatedMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _translateText('Chat with AI Assistant'),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Chat with AI Assistant',
              style: TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // Show info dialog about the chat assistant
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('About AI Assistant'),
                    content: Text(
                      'This AI assistant can help you with financial queries, bill reminders, loan information, and personalized financial advice based on your profile.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
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
          
          // "Bot is typing" indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'AI Assistant is typing',
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
                // Attachment button
                IconButton(
                  icon: Icon(Icons.mic, color: theme.colorScheme.primary),
                  onPressed: () {
                   Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>VoiceAssistantScreen()
                                ),
                              );
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