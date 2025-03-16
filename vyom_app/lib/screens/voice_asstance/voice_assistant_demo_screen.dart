import 'package:flutter/material.dart';
import 'package:vyom/screens/voice_asstance/voice_chat_bubble.dart';


class VoiceAssistantDemoScreen extends StatefulWidget {
  const VoiceAssistantDemoScreen({Key? key}) : super(key: key);

  @override
  State<VoiceAssistantDemoScreen> createState() => _VoiceAssistantDemoScreenState();
}

class _VoiceAssistantDemoScreenState extends State<VoiceAssistantDemoScreen> {
  String? _lastMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant Demo'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Voice Assistant Demo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Click on the voice bubble in the bottom right corner',
                  textAlign: TextAlign.center,
                ),
                if (_lastMessage != null) ...[
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Last Assistant Response:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_lastMessage!),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Voice chat bubble
          VoiceChatBubble(
            onMessageReceived: (message) {
              setState(() {
                _lastMessage = message;
              });
            },
          ),
        ],
      ),
    );
  }
}

