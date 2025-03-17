import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vyom/main.dart';
import 'package:vyom/screens/query_page/query_screen.dart';

// enum VoiceChatState {
//   initial,
//   listening,
//   processing,
//   speaking
// }

// class VoiceChatBubble extends StatefulWidget {
//   final Function()? onTap;
//   final Function()? onEnd;
//   final Function(String)? onMessageReceived;
//   final Function(String)? onUserMessage;
  
//   const VoiceChatBubble({
//     Key? key,
//     this.onTap,
//     this.onEnd,
//     this.onMessageReceived,
//     this.onUserMessage,
//   }) : super(key: key);

//   @override
//   State<VoiceChatBubble> createState() => _VoiceChatBubbleState();
// }

// class _VoiceChatBubbleState extends State<VoiceChatBubble> with SingleTickerProviderStateMixin {
//   VoiceChatState _state = VoiceChatState.initial;
//   late AnimationController _animationController;
//   bool _isExpanded = false;
//   bool _isInConversation = false;
  
//   // Speech recognition and TTS
//   late stt.SpeechToText _speech;
//   late FlutterTts _flutterTts;
//   String _recognizedText = "";
  
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat(reverse: true);
    
//     // Initialize speech recognition and TTS
//     _speech = stt.SpeechToText();
//     _flutterTts = FlutterTts();
//     _flutterTts.setLanguage("en-US");
//     _flutterTts.setPitch(1.0);
//     _flutterTts.setSpeechRate(0.5);
    
//     // Set up TTS completion handler to continue the conversation
//     _flutterTts.setCompletionHandler(() {
//       if (mounted && _isInConversation) {
//         _continueConversation();
//       }
//     });
//   }
  
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _flutterTts.stop();
//     super.dispose();
//   }
  
//   void _toggleExpanded() {
//   setState(() {
//     _isExpanded = !_isExpanded;
//     if (!_isExpanded) {
//       _endConversation();
//     }
//   });
// }
  
//   void _startConversation() async {
//     setState(() {
//       _isInConversation = true;
//     });
    
//     bool available = await _speech.initialize(
//       onStatus: (status) {
//         print("Speech status: $status");
//         if (status == 'notListening' && _recognizedText.isNotEmpty && _isInConversation) {
//           _processRecognizedSpeech();
//         }
//       },
//       onError: (error) => print("Speech error: $error"),
//     );

//     if (available) {
//       _startListening();
//     } else {
//       print("Speech recognition not available");
//       setState(() {
//         _isInConversation = false;
//         _state = VoiceChatState.initial;
//       });
//     }
//   }
  
//   void _startListening() {
//     if (!_isInConversation) return;
    
//     setState(() {
//       _state = VoiceChatState.listening;
//       _recognizedText = "";
//     });
    
//     _speech.listen(
//       onResult: (result) {
//         setState(() {
//           _recognizedText = result.recognizedWords;
//         });
        
//         if (result.finalResult && _recognizedText.isNotEmpty) {
//           _speech.stop();
//           _processRecognizedSpeech();
//         }
//       },
//       listenFor: const Duration(seconds: 10),
//       pauseFor: const Duration(seconds: 3),
//       partialResults: true,
//       localeId: "en_US",
//       cancelOnError: false,
//     );
//   }
  
//   void _processRecognizedSpeech() {
//     if (_recognizedText.isEmpty || !_isInConversation) return;
    
//     // Notify about user's message
//     if (widget.onUserMessage != null) {
//       widget.onUserMessage!(_recognizedText);
//     }
    
//     setState(() {
//       _state = VoiceChatState.processing;
//     });
    
//     // Generate response (you can replace with API call)
//     String response = _getMockResponse(_recognizedText);
    
//     // Slight delay to simulate processing
//     Timer(const Duration(milliseconds: 500), () {
//       if (mounted && _isInConversation) {
//         setState(() {
//           _state = VoiceChatState.speaking;
//         });
        
//         if (widget.onMessageReceived != null) {
//           widget.onMessageReceived!(response);
//         }
        
//         // Speak the response
//         _flutterTts.speak(response);
        
//         // The completion handler will call _continueConversation
//       }
//     });
//   }
  
//   void _continueConversation() {
//     if (!mounted || !_isInConversation) return;
    
//     // Small delay before starting to listen again
//     Timer(const Duration(milliseconds: 500), () {
//       if (mounted && _isInConversation) {
//         _startListening();
//       }
//     });
//   }
  
//   // Mock response generator
//   String _getMockResponse(String query) {
//     query = query.toLowerCase();
    
//     if (query.contains("hello") || query.contains("hi")) {
//       return "Hello! How can I help you today?";
//     } else if (query.contains("how are you")) {
//       return "I'm doing well, thank you for asking. How about you?";
//     } else if (query.contains("weather")) {
//       return "I don't have access to real-time weather data, but I can help you find a weather app if you'd like.";
//     } else if (query.contains("time")) {
//       final now = DateTime.now();
//       return "The current time is ${now.hour}:${now.minute.toString().padLeft(2, '0')}.";
//     } else if (query.contains("joke")) {
//       return "Why don't scientists trust atoms? Because they make up everything!";
//     } else if (query.contains("name")) {
//       return "I'm your voice assistant. How can I help you?";
//     } else if (query.contains("thank")) {
//       return "You're welcome! Is there anything else I can help you with?";
//     } else if (query.contains("bye") || query.contains("goodbye")) {
//       return "Goodbye! Have a great day!";
//     } else if (query.contains("i have a query")) {

//    navigatorKey.currentState?.push(
//   MaterialPageRoute(builder: (context) => VideoQueryScreen()),
// );

    
//     return "You can record your query here.";
//   }else {
//       return "I didn't quite catch that. Could you please try again?";
//     }
//   }
  
//  void _endConversation() {
//   _speech.stop();
//   _flutterTts.stop();
  
//   setState(() {
//     _state = VoiceChatState.initial;
//     _isInConversation = false;
//     _recognizedText = "";
//     _isExpanded = false; // Add this line to collapse the bubble
//   });
  
//   if (widget.onEnd != null) {
//     widget.onEnd!();
//   }
// }
  
//   String _getStateText() {
//     switch (_state) {
//       case VoiceChatState.initial:
//         return "Need help?";
//       case VoiceChatState.listening:
//         return _recognizedText.isEmpty ? "Listening..." : _recognizedText;
//       case VoiceChatState.processing:
//         return "Processing...";
//       case VoiceChatState.speaking:
//         return "Speaking";
//     }
//   }
  

//  @override
// Widget build(BuildContext context) {
//   return Positioned(
//     bottom: 20,
//     right: 20,
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: _isExpanded ? 280 : 60,
//       height: 60,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: _isExpanded ? _buildExpandedContent() : _buildCollapsedContent(),
//       ),
//     ),
//   );
// }
//   Widget _buildCollapsedContent() {
//   return InkWell(
//     onTap: _toggleExpanded,
//     borderRadius: BorderRadius.circular(30),
//     child: Container(
//       padding: const EdgeInsets.all(10),
//       child: _buildVoiceIcon(),
//     ),
//   );
// }
  
//   Widget _buildExpandedContent() {
//     return Row(
//       children: [
//         const SizedBox(width: 12),
//         _buildVoiceIcon(),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             _getStateText(),
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         if (!_isInConversation)
//           InkWell(
//             onTap: _startConversation,
//             borderRadius: BorderRadius.circular(20),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Text(
//                 "Voice chat",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           )
//         else
//           InkWell(
//             onTap: _endConversation,
//             borderRadius: BorderRadius.circular(20),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: const [
//                   Icon(
//                     Icons.close,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                   SizedBox(width: 4),
//                   Text(
//                     "End",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         const SizedBox(width: 12),
//       ],
//     );
//   }
  
//   Widget _buildVoiceIcon() {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: const BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFFE0E0E0),
//             Color(0xFFC0C0C0),
//             Color(0xFFD8D8D8),
//             Color(0xFFB0B0B0),
//           ],
//         ),
//       ),
//       child: _state == VoiceChatState.listening
//           ? _buildListeningAnimation()
//           : const Icon(
//               Icons.mic,
//               color: Colors.black54,
//             ),
//     );
//   }
  
//   Widget _buildListeningAnimation() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: SoundWavePainter(
//             animation: _animationController.value,
//           ),
//           child: const Icon(
//             Icons.mic,
//             color: Colors.black54,
//           ),
//         );
//       },
//     );
//   }
// }

// class SoundWavePainter extends CustomPainter {
//   final double animation;
  
//   SoundWavePainter({required this.animation});
  
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
    
//     final paint = Paint()
//       ..color = Colors.blue.withOpacity(0.3 * (1 - animation))
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
    
//     canvas.drawCircle(center, radius * animation, paint);
//     canvas.drawCircle(center, radius * animation * 0.7, paint);
//     canvas.drawCircle(center, radius * animation * 0.4, paint);
//   }
  
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vyom/main.dart';
import 'package:vyom/screens/query_page/query_screen.dart';
import 'package:vad/vad.dart';
import 'package:record/record.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
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

   VoiceChatBubble({
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
   final _vadHandler = VadHandler.create(isDebug: true);
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool isListening = false;
  bool isStopped = false;
  
  VoiceChatState _state = VoiceChatState.initial;
  late AnimationController _animationController;
  bool _isExpanded = false;
  bool _isInConversation = false;
  bool _isLanguageDropdownOpen = false;
  
  // Speech recognition and TTS
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  String _recognizedText = "";
  
  // Language selection
  String _currentLanguage = 'en';
  final Map<String, String> _languages = {
    'en': 'English',
    'hi': 'हिंदी (Hindi)',
    'ta': 'தமிழ் (Tamil)',
    'te': 'తెలుగు (Telugu)',
    'bn': 'বাংলা (Bengali)',
    'mr': 'मराठी (Marathi)',
    'gu': 'ગુજરાતી (Gujarati)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'ml': 'മലയാളം (Malayalam)',
    'pa': 'ਪੰਜਾਬੀ (Punjabi)',
    'or': 'ଓଡ଼ିଆ (Odia)',
  };
  
  // Language code to BCP-47 mapping for TTS
  final Map<String, String> _languageToBCP47 = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'bn': 'bn-IN',
    'mr': 'mr-IN',
    'gu': 'gu-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
    'pa': 'pa-IN',
    'or': 'or-IN',
  };
  
  // Key for the language dropdown
  final GlobalKey _languageButtonKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _setupVadHandler();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Initialize speech recognition and TTS
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _setLanguage(_currentLanguage);
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
    
    // Set up TTS completion handler to continue the conversation
    _flutterTts.setCompletionHandler(() {
      if (mounted && _isInConversation) {
        _continueConversation();
      }
    });
  }
  
void _setupVadHandler() {
    _vadHandler.onSpeechStart.listen((_) {
      print('🎤 Speech detected...');
      startRecording();
    });

    _vadHandler.onSpeechEnd.listen((_) async {
      print('🛑 Silence detected. Stopping recording...');
      await stopRecording();
      await sendAudioToBackend();
      await playAudioResponse();
    });

    _vadHandler.onError.listen((String message) {
      print('❌ VAD Error: $message');
    });
  }

Future<void> requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> startListening() async {
    await requestPermissions();
    setState(() => isStopped = false);
    _vadHandler.startListening();
  }

  Future<void> stopListening() async {
    setState(() => isStopped = true);
    _vadHandler.stopListening();
    print("⏹️ Stopped listening.");
  }

  Future<void> startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      await _audioRecorder.start(const RecordConfig(), path: "temp_audio.wav");
    }
  }

  Future<void> stopRecording() async {
    await _audioRecorder.stop();
  }

  Future<void> sendAudioToBackend() async {
    final file = File("temp_audio.wav");
    if (!await file.exists()) return;

    var formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(file.path, filename: "audio.wav"),
    });

    Dio dio = Dio();
    Response response = await dio.post("http://YOUR_SERVER_IP:8000/process_audio/", data: formData);

    if (response.statusCode == 200) {
      print("✅ Audio processed. Playing response...");
    } else {
      print("❌ Error in backend processing");
    }
  }

  Future<void> playAudioResponse() async {
    await _audioPlayer.setUrl("http://YOUR_SERVER_IP:8000/process_audio/");
    await _audioPlayer.play();
  }

  void _setLanguage(String langCode) {
    setState(() {
      _currentLanguage = langCode;
      _isLanguageDropdownOpen = false;
    });
    
    // Set TTS language
    _flutterTts.setLanguage(_languageToBCP47[langCode] ?? 'en-US');
  }
  
  @override
  void dispose() {
    _vadHandler.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _animationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isLanguageDropdownOpen = false;
      if (!_isExpanded) {
        _endConversation();
      }
    });
  }
  
  void _startConversation() async {
    setState(() {
      _isInConversation = true;
      _isLanguageDropdownOpen = false;
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
      localeId: _getLocaleId(_currentLanguage),
      cancelOnError: false,
    );
  }
  
  String _getLocaleId(String langCode) {
    // Map language code to locale ID for speech recognition
    switch (langCode) {
      case 'en': return 'en_US';
      case 'hi': return 'hi_IN';
      case 'ta': return 'ta_IN';
      case 'te': return 'te_IN';
      case 'bn': return 'bn_IN';
      case 'mr': return 'mr_IN';
      case 'gu': return 'gu_IN';
      case 'kn': return 'kn_IN';
      case 'ml': return 'ml_IN';
      case 'pa': return 'pa_IN';
      case 'or': return 'or_IN';
      default: return 'en_US';
    }
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
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => VideoQueryScreen()),
      );
      return "You can record your query here.";
    } else {
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
      _isExpanded = false;
      _isLanguageDropdownOpen = false;
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
  
  void _toggleLanguageDropdown() {
    setState(() {
      _isLanguageDropdownOpen = !_isLanguageDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isLanguageDropdownOpen)
            Container(
              width: 200,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _languages.entries.map((entry) {
                    return InkWell(
                      onTap: () => _setLanguage(entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _currentLanguage == entry.key ? Colors.grey.shade100 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _getLanguageFlag(entry.key),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _currentLanguage == entry.key ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_currentLanguage == entry.key)
                              const Icon(Icons.check, size: 16, color: Colors.blue),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          AnimatedContainer(
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
        ],
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => isListening ? stopListening() : startListening(),
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
                        Icons.phone,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Voice chat",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                key: _languageButtonKey,
                onTap: _toggleLanguageDropdown,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _getLanguageFlag(_currentLanguage),
                      const SizedBox(width: 4),
                      Icon(
                        _isLanguageDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
  
  Widget _getLanguageFlag(String langCode) {
    // Simple flag representation - in a real app, you'd use proper flag images
    switch (langCode) {
      case 'en':
        return Container(
          width: 24,
          height: 16,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/flags/us.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case 'hi':
      case 'ta':
      case 'te':
      case 'bn':
      case 'mr':
      case 'gu':
      case 'kn':
      case 'ml':
      case 'pa':
      case 'or':
        return Container(
          width: 24,
          height: 16,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/flags/india.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      default:
        return Container(
          width: 24,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(2),
          ),
        );
    }
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