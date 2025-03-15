import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vyom/screens/query_page/query_screen.dart';

class VoiceAssistantScreen extends StatefulWidget {
  @override
  _VoiceAssistantScreenState createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> with TickerProviderStateMixin {
  bool _isListening = false;
  String _promptText = "Tap the mic to start";
  String _queryText = "";
  String _responseText = "";
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  final List<AnimationController> _waveControllers = [];
  final List<Animation<double>> _waveAnimations = [];
  
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  
  // Theme colors
  final Color primaryColor = const Color(0xFF233B99);
  final Color secondaryColor = const Color.fromARGB(255, 213, 220, 248);
  final Color surfaceColor = Colors.white;
  final Color backgroundColor = const Color(0xFF121212);
  final Color onPrimaryColor = Colors.white;
  final Color onSecondaryColor = Colors.black;
  final Color onSurfaceColor = Colors.black;
  final Color onBackgroundColor = Colors.white;
  final Color errorColor = const Color(0xFFE63946);

  @override
  void initState() {
    super.initState();
    
    // Set system UI overlay style to match dark theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    
    // Initialize speech recognition and TTS
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
    
    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Initialize wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    
    // Create multiple wave animations for the voice visualization
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 1500 + (i * 500)),
        vsync: this,
      )..repeat();
      
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
      
      _waveControllers.add(controller);
      _waveAnimations.add(animation);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    for (var controller in _waveControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print("Status: $status"),
        onError: (error) => print("Error: $error"),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _promptText = "Go ahead, I'm listening";
        });

        _speech.listen(onResult: (result) {
          setState(() {
            _queryText = result.recognizedWords;
          });

          if (result.finalResult && _queryText.isNotEmpty) {
            _speech.stop();
            setState(() {
              _isListening = false;
              _promptText = "Tap the mic to start";
            });
            _generateResponse(_queryText);
          }
        });
      }
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
        _promptText = "Tap the mic to start";
      });
    }
  }

  // Generate and speak response
  void _generateResponse(String query) async {
    if (query.isEmpty) return;

    // Example response (you can replace this with API-based response)
    String response = _getMockResponse(query);

    setState(() {
      _responseText = response;
    });

    // Speak the response
    await _flutterTts.speak(response);
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
      return "I'm Gem Voice, your voice assistant. How can I help you?";
    } else if (query.contains("thank")) {
      return "You're welcome! Is there anything else I can help you with?";
    } else if (query.contains("bye") || query.contains("goodbye")) {
      return "Goodbye! Have a great day!";
    } else if (query.contains("digital abstract design") || query.contains("abstract design")) {
      return "Digital abstract design refers to non-representational art created using digital tools. It often features geometric shapes, vibrant colors, and fluid patterns. Three examples include: 1) Fractal art with intricate mathematical patterns, 2) Generative art created using algorithms, and 3) Digital collages combining various abstract elements for a unified composition.";
    } else if (query.contains("i have a query")) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoQueryScreen()),
    );
    
    return "You can record your query here.";
  }
    
    return "I didn't quite catch that. Could you please try again?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _buildBody(),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(Icons.arrow_back),
          Text(
            'Gem Voice',
            style: TextStyle(
              color: onBackgroundColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          _buildCircleButton(Icons.more_horiz),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: onBackgroundColor,
        size: 20,
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            _promptText,
            style: TextStyle(
              color: onBackgroundColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
        _buildVoiceVisualization(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_queryText.isNotEmpty)
                Text(
                  _queryText,
                  style: TextStyle(
                    color: onBackgroundColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_responseText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    _responseText,
                    style: TextStyle(
                      color: onBackgroundColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceVisualization() {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          
          // Multiple animated rings
          ..._waveAnimations.asMap().entries.map((entry) {
            final i = entry.key;
            final animation = entry.value;
            
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Opacity(
                  opacity: (1.0 - animation.value) * 0.8,
                  child: Container(
                    width: 150 + (animation.value * 30),
                    height: 150 + (animation.value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7 - (i * 0.2)),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
          
          // Inner circle with gradient
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primaryColor.withOpacity(0.7),
                  primaryColor.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: [0.4, 0.8, 1.0],
                center: Alignment(0.2, -0.3),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 1.5,
              ),
            ),
          ),
          
          // Voice waves when listening
          if (_isListening)
            ..._buildVoiceWaves(),
        ],
      ),
    );
  }

  List<Widget> _buildVoiceWaves() {
    final List<Widget> waves = [];
    final random = Random();
    
    for (int i = 0; i < 8; i++) {
      final startAngle = random.nextDouble() * 2 * pi;
      final length = 20.0 + random.nextDouble() * 30;
      
      waves.add(
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            final angle = startAngle + (_waveController.value * 2 * pi / 8);
            final x = 70 * cos(angle);
            final y = 70 * sin(angle);
            
            return Positioned(
              left: 100 + x - (length / 2),
              top: 100 + y - 1,
              child: Transform.rotate(
                angle: angle + (pi / 2),
                child: Container(
                  width: length,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return waves;
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(Icons.chat_bubble_outline),
          _buildMicButton(),
          _buildControlButton(Icons.close),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.3),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: onBackgroundColor,
        size: 24,
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isListening ? primaryColor : Colors.black.withOpacity(0.3),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: _isListening
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
                ]
              : [],
        ),
        child: Icon(
          Icons.mic,
          color: onBackgroundColor,
          size: 30,
        ),
      ),
    );
  }
}