import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vyom/screens/query_page/query_screen.dart';

enum VoiceChatState {
  initial,
  listening,
  processing,
  speaking
}

class VoiceChatBubble extends StatefulWidget {
  final Function()? onTap;
  final Function()? onEnd;
  final Function(String)? onMessageReceived;
  final Function(String)? onUserMessage;
  
  const VoiceChatBubble({
    Key? key,
    this.onTap,
    this.onEnd,
    this.onMessageReceived,
    this.onUserMessage,
  }) : super(key: key);

  @override
  State<VoiceChatBubble> createState() => _VoiceChatBubbleState();
}

class _VoiceChatBubbleState extends State<VoiceChatBubble> with SingleTickerProviderStateMixin {
  VoiceChatState _state = VoiceChatState.initial;
  late AnimationController _animationController;
  bool _isExpanded = false;
  bool _isInConversation = false;
  
  // Speech recognition and TTS
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  String _recognizedText = "";
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Initialize speech recognition and TTS
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
    
    // Set up TTS completion handler to continue the conversation
    _flutterTts.setCompletionHandler(() {
      if (mounted && _isInConversation) {
        _continueConversation();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
  
  void _toggleExpanded() {
  setState(() {
    _isExpanded = !_isExpanded;
    if (!_isExpanded) {
      _endConversation();
    }
  });
}
  
  void _startConversation() async {
    setState(() {
      _isInConversation = true;
    });
    
    bool available = await _speech.initialize(
      onStatus: (status) {
        print("Speech status: $status");
        if (status == 'notListening' && _recognizedText.isNotEmpty && _isInConversation) {
          _processRecognizedSpeech();
        }
      },
      onError: (error) => print("Speech error: $error"),
    );

    if (available) {
      _startListening();
    } else {
      print("Speech recognition not available");
      setState(() {
        _isInConversation = false;
        _state = VoiceChatState.initial;
      });
    }
  }
  
  void _startListening() {
    if (!_isInConversation) return;
    
    setState(() {
      _state = VoiceChatState.listening;
      _recognizedText = "";
    });
    
    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        
        if (result.finalResult && _recognizedText.isNotEmpty) {
          _speech.stop();
          _processRecognizedSpeech();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: "en_US",
      cancelOnError: false,
    );
  }
  
  void _processRecognizedSpeech() {
    if (_recognizedText.isEmpty || !_isInConversation) return;
    
    // Notify about user's message
    if (widget.onUserMessage != null) {
      widget.onUserMessage!(_recognizedText);
    }
    
    setState(() {
      _state = VoiceChatState.processing;
    });
    
    // Generate response (you can replace with API call)
    String response = _getMockResponse(_recognizedText);
    
    // Slight delay to simulate processing
    Timer(const Duration(milliseconds: 500), () {
      if (mounted && _isInConversation) {
        setState(() {
          _state = VoiceChatState.speaking;
        });
        
        if (widget.onMessageReceived != null) {
          widget.onMessageReceived!(response);
        }
        
        // Speak the response
        _flutterTts.speak(response);
        
        // The completion handler will call _continueConversation
      }
    });
  }
  
  void _continueConversation() {
    if (!mounted || !_isInConversation) return;
    
    // Small delay before starting to listen again
    Timer(const Duration(milliseconds: 500), () {
      if (mounted && _isInConversation) {
        _startListening();
      }
    });
  }
  
  // Mock response generator
  String _getMockResponse(String query) {
    query = query.toLowerCase();
    
    if (query.contains("hello") || query.contains("hi")) {
      return "Hello! How can I help you today?";
    } else if (query.contains("how are you")) {
      return "I'm doing well, thank you for asking. How about you?";
    } else if (query.contains("weather")) {
      return "I don't have access to real-time weather data, but I can help you find a weather app if you'd like.";
    } else if (query.contains("time")) {
      final now = DateTime.now();
      return "The current time is ${now.hour}:${now.minute.toString().padLeft(2, '0')}.";
    } else if (query.contains("joke")) {
      return "Why don't scientists trust atoms? Because they make up everything!";
    } else if (query.contains("name")) {
      return "I'm your voice assistant. How can I help you?";
    } else if (query.contains("thank")) {
      return "You're welcome! Is there anything else I can help you with?";
    } else if (query.contains("bye") || query.contains("goodbye")) {
      return "Goodbye! Have a great day!";
    } else if (query.contains("i have a query")) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoQueryScreen()),
    );
    
    return "You can record your query here.";
  }else {
      return "I didn't quite catch that. Could you please try again?";
    }
  }
  
 void _endConversation() {
  _speech.stop();
  _flutterTts.stop();
  
  setState(() {
    _state = VoiceChatState.initial;
    _isInConversation = false;
    _recognizedText = "";
    _isExpanded = false; // Add this line to collapse the bubble
  });
  
  if (widget.onEnd != null) {
    widget.onEnd!();
  }
}
  
  String _getStateText() {
    switch (_state) {
      case VoiceChatState.initial:
        return "Need help?";
      case VoiceChatState.listening:
        return _recognizedText.isEmpty ? "Listening..." : _recognizedText;
      case VoiceChatState.processing:
        return "Processing...";
      case VoiceChatState.speaking:
        return "Speaking";
    }
  }
  

 @override
Widget build(BuildContext context) {
  return Positioned(
    bottom: 20,
    right: 20,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 280 : 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
      ),
    ),
  );
}
  Widget _buildCollapsedContent() {
  return InkWell(
    onTap: _toggleExpanded,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      padding: const EdgeInsets.all(10),
      child: _buildVoiceIcon(),
    ),
  );
}
  
  Widget _buildExpandedContent() {
    return Row(
      children: [
        const SizedBox(width: 12),
        _buildVoiceIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _getStateText(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!_isInConversation)
          InkWell(
            onTap: _startConversation,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Voice chat",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          InkWell(
            onTap: _endConversation,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "End",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 12),
      ],
    );
  }
  
  Widget _buildVoiceIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0E0E0),
            Color(0xFFC0C0C0),
            Color(0xFFD8D8D8),
            Color(0xFFB0B0B0),
          ],
        ),
      ),
      child: _state == VoiceChatState.listening
          ? _buildListeningAnimation()
          : const Icon(
              Icons.mic,
              color: Colors.black54,
            ),
    );
  }
  
  Widget _buildListeningAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: SoundWavePainter(
            animation: _animationController.value,
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.black54,
          ),
        );
      },
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final double animation;
  
  SoundWavePainter({required this.animation});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3 * (1 - animation))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(center, radius * animation, paint);
    canvas.drawCircle(center, radius * animation * 0.7, paint);
    canvas.drawCircle(center, radius * animation * 0.4, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

