import 'package:acp/acp.dart';
import 'package:aria/features/chat/permission_prompt.dart';
import 'package:aria/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('answers the permission request once', (tester) async {
    String? answered;
    var answers = 0;

    final request = PermissionRequest(
      sessionId: 's1',
      toolCall: const ToolCallInfo(id: 'call-1', title: 'Write file'),
      options: const <PermissionOption>[
        PermissionOption(
          kind: 'allow_once',
          name: 'Allow once',
          optionId: 'allow_once',
        ),
        PermissionOption(
          kind: 'reject_once',
          name: 'Reject',
          optionId: 'reject_once',
        ),
      ],
      respond: (optionId) async {
        answers++;
        answered = optionId;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PermissionPrompt(
            request: request,
            onAllow: request.allow,
            onDeny: request.deny,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Approve tool call'), findsOneWidget);
    expect(find.text('Write file'), findsOneWidget);

    await tester.tap(find.text('Allow once'));
    await tester.pumpAndSettle();

    expect(answered, 'allow_once');
    expect(answers, 1);

    // A second tap cannot answer again: the request is idempotent.
    await tester.tap(find.text('Allow once'));
    await tester.pumpAndSettle();
    expect(answers, 1);
  });
}
