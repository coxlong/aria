import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/conversation_reducer.dart';
import 'process_sheet.dart';

/// Scrollable conversation.
final class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.controller,
    required this.messages,
  });

  final ScrollController controller;
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: messages.length,
      itemBuilder: (context, index) => MessageView(message: messages[index]),
    );
  }
}

/// One conversation message.
final class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = message.processSteps;

    return Column(
      crossAxisAlignment: message.role == 'user'
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (message.role != 'user' && steps.isNotEmpty)
          TextButton(
            onPressed: () => showProcessSheet(context, message),
            child: Text(
              message.streaming
                  ? l10n.processRunning(steps.length)
                  : l10n.processCompleted(steps.length),
            ),
          ),
        if (message.hasText) Text(message.content),
        if (message.streaming) const LinearProgressIndicator(),
      ],
    );
  }
}
