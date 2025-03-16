import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:vyom/screens/query_page/query_screen.dart';
import 'package:vyom/screens/voice_asstance/voice_chat_bubble.dart';
class VoiceChatNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final List<Page<dynamic>> pages;
  final GoogleTranslator translator;
  final String currentLanguage;
  
  const VoiceChatNavigator({
    Key? key,
    required this.navigatorKey,
    required this.pages,
    required this.translator,
    required this.currentLanguage,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Navigator(
          key: navigatorKey,
          pages: pages,
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            return true;
          },
        ),
        Builder(
          builder: (innerContext) => VoiceChatBubble(
            onMessageReceived: (message) {
              print("Assistant: $message");
            },
            onUserMessage: (message) {
              print("User: $message");
              // You might need to handle the navigation here as well
              if (message.toLowerCase().contains("i have a query")) {
                Navigator.of(innerContext).push(
                  MaterialPageRoute(builder: (context) => VideoQueryScreen()),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}