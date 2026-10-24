import 'package:acp/acp.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// A blocking permission decision.
///
/// Rendered above the chat instead of as a dismissible dialog: the agent is
/// blocked on this answer, so tapping outside must not close it. The only ways
/// out are an explicit option or a cancel.
final class PermissionPrompt extends StatelessWidget {
  const PermissionPrompt({
    super.key,
    required this.request,
    required this.onAllow,
    required this.onDeny,
  });

  final PermissionRequest request;
  final Future<void> Function(String optionId) onAllow;
  final Future<void> Function() onDeny;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tool = request.toolCall;

    return Stack(
      children: [
        const ModalBarrier(dismissible: false),
        Center(
          child: AlertDialog(
            title: Text(l10n.permissionTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.permissionHint),
                  Text(tool.title),
                  for (final option in request.options)
                    TextButton(
                      onPressed: () => onAllow(option.optionId),
                      child: Text(_optionLabel(l10n, option)),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: onDeny, child: Text(l10n.permissionCancel)),
            ],
          ),
        ),
      ],
    );
  }

  static String _optionLabel(AppLocalizations l10n, PermissionOption option) =>
      switch (option.kind) {
        'allow_once' => l10n.allowOnce,
        'allow_always' => l10n.allowAlways,
        'reject_once' => l10n.rejectOnce,
        'reject_always' => l10n.rejectAlways,
        _ => option.name,
      };
}
