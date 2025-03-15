import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Command {
  static final all = [email, browser1, browser2];

  static const email = 'write email';
  static const browser1 = 'open';
  static const browser2 = 'go to';
}

class Utils {
  static void scanText(String rawText) {
    final text = rawText.toLowerCase();

    if (text.contains(Command.email)) {
      final body = _getTextAfterCommand(text: text, command: Command.email) ?? '';
      openEmail(body: body);
    } else if (text.contains(Command.browser1)) {
      final url = _getTextAfterCommand(text: text, command: Command.browser1) ?? 'google.com';
      openLink(url: url);
    } else if (text.contains(Command.browser2)) {
      final url = _getTextAfterCommand(text: text, command: Command.browser2) ?? 'google.com';
      openLink(url: url);
    }
  }

  static String? _getTextAfterCommand({
    required String text,
    required String command,
  }) {
    final indexCommand = text.indexOf(command);
    if (indexCommand == -1) return null;

    final indexAfter = indexCommand + command.length;
    return indexAfter < text.length ? text.substring(indexAfter).trim() : null;
  }

  static Future<void> openLink({required String url}) async {
    final formattedUrl = url.startsWith('http') ? url : 'https://$url';
    await _launchUrl(formattedUrl);
  }

  static Future<void> openEmail({required String body}) async {
    final url = 'mailto:?body=${Uri.encodeFull(body)}';
    await _launchUrl(url);
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Could not launch $url');
    }
  }
}
