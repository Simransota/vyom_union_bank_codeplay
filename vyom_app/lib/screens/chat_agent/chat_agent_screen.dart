import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool hasAttachment;
  final VoidCallback? onAttachmentTap;
  final String? attachmentName;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.hasAttachment = false,
    this.onAttachmentTap,
    this.attachmentName,
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
                          _getFileIcon(attachmentName ?? ''),
                          color: textColor.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          attachmentName ?? 'View Attachment',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
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

  // Helper method to determine file icon based on file extension
  IconData _getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
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
  File? _selectedFile;
  String? _selectedFileName;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty && _selectedFile == null) return;

    final userMessage = _messageController.text;
    _messageController.clear();
    
    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(
        message: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
        hasAttachment: _selectedFile != null,
        attachmentFile: _selectedFile,
        attachmentName: _selectedFileName,
      ));
      _selectedFile = null;
      _selectedFileName = null;
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
    if (userMessage.isEmpty && _messages.last.hasAttachment) {
      return 'Thanks for sharing the document! I\'ll take a look at it.';
    } else if (userMessage.toLowerCase().contains('hello')) {
      return 'Hi there! How are you doing today?';
    } else if (userMessage.toLowerCase().contains('how are you')) {
      return 'I\'m doing great, thanks for asking! What\'s up?';
    } else {
      return 'I didn\'t quite catch that, can you say it again?';
    }
  }

  // Method to open file picker
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
        
        // Show selected file indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: $_selectedFileName'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Cancel',
              onPressed: () {
                setState(() {
                  _selectedFile = null;
                  _selectedFileName = null;
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to view document
  void _viewDocument(File file, String? fileName) {
    // In a real app, you would open the file with the appropriate viewer
    // or display it in your app using packages like pdf_viewer, image viewers, etc.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Document: ${fileName ?? 'Attachment'}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFileIconForDialog(fileName ?? ''),
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('File path: ${file.path}'),
              const SizedBox(height: 8),
              Text('This is where you would integrate a file viewer'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getFileIconForDialog(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return Icons.image;
      case '.mp4':
      case '.mov':
      case '.avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
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
                  attachmentName: message.attachmentName,
                  onAttachmentTap: message.hasAttachment && message.attachmentFile != null 
                      ? () => _viewDocument(message.attachmentFile!, message.attachmentName) 
                      : null,
                );
              },
            ),
          ),
          
          // Selected file indicator
          if (_selectedFile != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surface,
              child: Row(
                children: [
                  Icon(
                    _getFileIconForDialog(_selectedFileName ?? ''),
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedFileName ?? 'File selected',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedFile = null;
                        _selectedFileName = null;
                      });
                    },
                  ),
                ],
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
                // Attachment button
                IconButton(
                  icon: Icon(Icons.attach_file, color: theme.colorScheme.primary),
                  onPressed: _pickFile,
                ),
                
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _selectedFile != null 
                          ? 'Add a message or send the file...' 
                          : 'Type your message...',
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
  final File? attachmentFile;
  final String? attachmentName;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.hasAttachment = false,
    this.attachmentFile,
    this.attachmentName,
  });
}