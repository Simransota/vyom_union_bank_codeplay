import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isAgent;
  final String time;

  const ChatMessage({
    Key? key,
    required this.message,
    required this.isAgent,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isAgent ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAgent) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.support_agent, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAgent ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAgent
                        ? theme.colorScheme.secondary.withOpacity(0.3)
                        : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomLeft: isAgent ? Radius.zero : null,
                      bottomRight: !isAgent ? Radius.zero : null,
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isAgent
                          ? theme.colorScheme.onBackground
                          : theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          if (!isAgent) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.person_outline, size: 20, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

