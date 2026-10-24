import 'dart:convert';

import 'package:acp/acp.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../state/conversation_reducer.dart';

/// Shows the ordered thinking/tool steps for one assistant message.
Future<void> showProcessSheet(BuildContext context, ChatMessage message) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => ListView(
      shrinkWrap: true,
      children: [
        for (final step in message.processSteps)
          ListTile(
            title: Text(step.summary),
            subtitle: Text(
              step.kind == 'tool'
                  ? (step.tool?.status ?? step.tool?.title ?? '')
                  : AppLocalizations.of(sheetContext).thinking,
            ),
            onTap: () => _showStepDetails(sheetContext, step),
          ),
      ],
    ),
  );
}

Future<void> _showStepDetails(BuildContext context, TurnStep step) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.stepDetails),
      content: SingleChildScrollView(
        child: Text(
          step.kind == 'thinking'
              ? (step.thinking ?? '')
              : _toolDetails(l10n, step.tool),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}

String _toolDetails(AppLocalizations l10n, ToolCallInfo? tool) {
  if (tool == null) return '';
  final buffer = StringBuffer()..writeln(tool.title);
  final name = tool.toolName ?? tool.kind;
  if (name != null && name.isNotEmpty) buffer.writeln(name);
  if (tool.status != null) {
    buffer.writeln('${l10n.status}: ${tool.status}');
  }

  final input = _encode(tool.rawInput);
  if (input.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(l10n.toolInput)
      ..writeln(input);
  }

  final content = tool.contentText;
  final output = content.isNotEmpty ? content : _encode(tool.rawOutput);
  if (output.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(l10n.toolOutput)
      ..writeln(output);
  }
  return buffer.toString();
}

String _encode(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } on Object {
    return value.toString();
  }
}
