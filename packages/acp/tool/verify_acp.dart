import 'dart:async';
import 'dart:io';

import 'package:acp/acp.dart';

/// End-to-end verifier for the ACP client against a live bridge/agent.
///
/// Usage:
///   dart run tool/verify_acp.dart [ws-url] [cwd] [--token=...] [--cancel]
///
/// The script drives every client method that can be exercised safely:
/// initialize, session/list, session/new, session/prompt (with streaming and
/// permission handling), set_model, set_mode, set_config_option, session/cancel
/// (opt-in), session/close and session/load.
const Duration _stepTimeout = Duration(seconds: 30);
const Duration _promptTimeout = Duration(seconds: 120);

Future<void> main(List<String> args) async {
  final flags = args.where((arg) => arg.startsWith('--')).toList();
  final positional = args.where((arg) => !arg.startsWith('--')).toList();

  final url = Uri.parse(
    positional.isNotEmpty ? positional[0] : 'ws://127.0.0.1:3000',
  );
  final cwd = positional.length > 1 ? positional[1] : Directory.current.path;
  final token = _flagValue(flags, '--token') ?? '';
  final wantsCancel = flags.contains('--cancel');
  final wantsPermission = flags.contains('--permission');

  stdout
    ..writeln('Aria ACP verifier')
    ..writeln('  url   : $url')
    ..writeln('  cwd   : $cwd')
    ..writeln('  token : ${token.isEmpty ? '(none)' : 'provided'}')
    ..writeln('  cancel: $wantsCancel')
    ..writeln('  permission prompt: $wantsPermission')
    ..writeln('');

  final report = _Report();
  AcpClient? client;

  try {
    final transport = await WsTransport.connect(
      url,
      token: token.isEmpty ? null : token,
    );
    client = AcpClient(transport);
    report.pass('transport.connect', 'state=${transport.state}');

    final init = await client.initialize().timeout(_stepTimeout);
    report.pass(
      'initialize',
      'version=${init.protocolVersion} '
          'loadSession=${init.supportsLoadSession} '
          'sessionList=${init.supportsSessionList} '
          'auth=${init.authMethods.map((method) => method.id).join(",")}',
    );

    if (init.authMethods.isEmpty) {
      report.skip('authenticate', 'agent advertises no auth method');
    } else {
      report.skip(
        'authenticate',
        'agent advertises ${init.authMethods.map((m) => m.id).join(", ")}; '
            'not attempted automatically',
      );
    }

    try {
      final sessions = await client
          .listSessions(cwd: cwd)
          .timeout(_stepTimeout);
      report.pass('session/list', '${sessions.length} session(s)');
    } on AcpRemoteError catch (error) {
      report.skip(
        'session/list',
        'agent does not implement it (code ${error.code})',
      );
    } on TimeoutException {
      report.fail('session/list', 'timed out');
    }

    final session = await client.newSession(cwd: cwd).timeout(_stepTimeout);
    report.pass('session/new', 'id=${session.id}');
    _printSurfaces(session);

    final counts = <String, int>{};
    final updateSubscription = session.updates.listen((update) {
      final kind = update.runtimeType.toString();
      final count = (counts[kind] ?? 0) + 1;
      counts[kind] = count;
      if (count <= 3) {
        stdout.writeln('    update $kind: ${_summarize(update)}');
      }
    });

    var permissionCount = 0;
    final permissionSubscription = client.permissionRequests.listen((
      request,
    ) async {
      permissionCount++;
      final kinds = request.options.map((option) => option.kind).join(', ');
      stdout.writeln('    permission: ${request.toolCall.title} [$kinds]');
      PermissionOption? allow;
      for (final option in request.options) {
        if (option.kind.startsWith('allow')) {
          allow = option;
          break;
        }
      }
      try {
        if (allow == null) {
          await request.deny();
          report.pass(
            'session/request_permission',
            'cancelled (agent offered no allow option)',
          );
        } else {
          await request.allow(allow.optionId);
          report.pass(
            'session/request_permission',
            'allowed ${allow.optionId}',
          );
        }
      } on Object catch (error) {
        report.fail('session/request_permission', error);
      }
    });

    final promptFuture = session.prompt(
      wantsPermission
          ? 'Create a file named aria-permission-check.txt in the current '
                'working directory containing the text "ok", then reply with '
                'exactly: done.'
          : 'Use the bash tool to run `echo aria-verify`, then reply with '
                'exactly its output.',
    );
    PromptResult promptResult;
    try {
      promptResult = await promptFuture.timeout(_promptTimeout);
    } on TimeoutException {
      await session.cancel();
      promptResult = await promptFuture.timeout(
        const Duration(seconds: 15),
        onTimeout: () => const PromptResult('timeout'),
      );
    }
    report.pass('session/prompt', 'stopReason=${promptResult.stopReason}');

    if ((counts['AgentMessageChunk'] ?? 0) > 0) {
      report.pass('stream agent_message_chunk');
    } else {
      report.fail('stream agent_message_chunk', 'no text chunk observed');
    }
    if ((counts['AgentThoughtChunk'] ?? 0) > 0) {
      report.pass('stream agent_thought_chunk');
    } else {
      report.skip('stream agent_thought_chunk', 'agent streamed no thinking');
    }
    if ((counts['ToolCallStarted'] ?? 0) > 0) {
      report.pass('stream tool_call');
    } else {
      report.skip('stream tool_call', 'agent used no tools');
    }
    if ((counts['ToolCallPatched'] ?? 0) > 0) {
      report.pass('stream tool_call_update');
    } else {
      report.skip('stream tool_call_update', 'no tool call patches observed');
    }

    if (permissionCount == 0) {
      report.skip(
        'session/request_permission',
        'agent did not request approval for this turn',
      );
    }

    await _verifyModel(session, report);
    await _verifyMode(session, report);
    await _verifyEffort(session, report);

    if (wantsCancel) {
      final cancelFuture = session.prompt(
        'Count from 1 to 50, one number per line.',
      );
      await Future<void>.delayed(const Duration(milliseconds: 800));
      await session.cancel();
      final cancelResult = await cancelFuture.timeout(
        _stepTimeout,
        onTimeout: () => const PromptResult('timeout'),
      );
      report.pass('session/cancel', 'stopReason=${cancelResult.stopReason}');
    } else {
      report.skip('session/cancel', 'pass --cancel to exercise it');
    }

    final sessionId = session.id;
    await updateSubscription.cancel();
    await session.close().timeout(_stepTimeout);
    report.pass('session/close');

    if (!init.supportsLoadSession) {
      report.skip('session/load', 'agent does not advertise loadSession');
    } else {
      try {
        final loaded = await client
            .loadSession(sessionId: sessionId, cwd: cwd)
            .timeout(const Duration(seconds: 60));
        var replayed = 0;
        final loadSubscription = loaded.updates.listen((_) => replayed++);
        await Future<void>.delayed(const Duration(seconds: 1));
        await loadSubscription.cancel();

        report.pass('session/load', 'id=${loaded.id} replayed=$replayed');
        if (replayed == 0) {
          report.fail('session/load replay', 'no replayed updates observed');
        }
        await loaded.close().timeout(_stepTimeout);
        report.pass('session/close (loaded)');
      } on Object catch (error) {
        report.fail('session/load', error);
      }
    }

    await permissionSubscription.cancel();
  } on Object catch (error, stackTrace) {
    report.fail('fatal', error);
    stderr.writeln(stackTrace);
  } finally {
    await client?.close();
  }

  stdout
    ..writeln('')
    ..writeln(report.summary);

  exitCode = report.failed == 0 ? 0 : 1;
}

Future<void> _verifyModel(AcpSession session, _Report report) async {
  final models = session.models;
  if (!models.hasModels) {
    report.skip('session/set_model', 'agent advertises no models');
    return;
  }
  final target = _differentValue(
    models.available.map((model) => model.modelId).toList(),
    models.currentModelId,
  );
  try {
    await session.setModel(target).timeout(_stepTimeout);
    report.pass(
      'session/set_model',
      '${models.currentModelId ?? "(none)"} -> $target',
    );
  } on Object catch (error) {
    report.fail('session/set_model', error);
  }
}

Future<void> _verifyMode(AcpSession session, _Report report) async {
  final modes = session.modes;
  if (!modes.hasModes) {
    report.skip('session/set_mode', 'agent advertises no modes');
    return;
  }
  final target = _differentValue(
    modes.available.map((mode) => mode.id).toList(),
    modes.currentModeId,
  );
  try {
    await session.setMode(target).timeout(_stepTimeout);
    report.pass(
      'session/set_mode',
      '${modes.currentModeId ?? "(none)"} -> $target',
    );
  } on Object catch (error) {
    report.fail('session/set_mode', error);
  }
}

Future<void> _verifyEffort(AcpSession session, _Report report) async {
  final efforts = session.efforts;
  final configId = efforts.configId;
  if (!efforts.hasEfforts || configId == null) {
    report.skip(
      'session/set_config_option',
      'agent advertises no thought_level option',
    );
    return;
  }
  final target = _differentValue(
    efforts.available.map((effort) => effort.value).toList(),
    efforts.currentValue,
  );
  try {
    await session.setConfigOption(configId, target).timeout(_stepTimeout);
    report.pass(
      'session/set_config_option',
      '$configId: ${efforts.currentValue ?? "(none)"} -> $target',
    );
  } on Object catch (error) {
    report.fail('session/set_config_option', error);
  }
}

String _differentValue(List<String> values, String? current) {
  if (values.isEmpty) return current ?? '';
  for (final value in values) {
    if (value != current && value.isNotEmpty) return value;
  }
  return current ?? values.first;
}

String? _flagValue(List<String> flags, String name) {
  for (final flag in flags) {
    if (flag.startsWith('$name=')) {
      return flag.substring(name.length + 1);
    }
  }
  return null;
}

void _printSurfaces(AcpSession session) {
  final models = session.models;
  final modes = session.modes;
  final efforts = session.efforts;
  stdout.writeln(
    '    surfaces: models=${models.available.length} '
    'currentModel=${models.currentDisplay ?? "(none)"} '
    'modes=${modes.available.length} '
    'currentMode=${modes.currentDisplay ?? "(none)"} '
    'efforts=${efforts.available.length} '
    'currentEffort=${efforts.currentDisplay ?? "(none)"}',
  );
}

String _summarize(SessionUpdate update) => switch (update) {
  UserMessageChunk(:final text) => _truncate(text),
  AgentMessageChunk(:final text) => _truncate(text),
  AgentThoughtChunk(:final text) => _truncate(text),
  ToolCallStarted(:final toolCall) =>
    '${toolCall.title} kind=${toolCall.kind ?? "?"} '
        'status=${toolCall.status ?? "?"}',
  ToolCallPatched(:final toolCallId, :final status) =>
    '$toolCallId status=${status ?? "?"}',
  CurrentModeUpdate(:final modeId) => modeId,
  ConfigOptionUpdate(:final configOptions) =>
    '${configOptions.length} option(s)',
  UnknownSessionUpdate(:final kind) => 'kind=$kind',
};

String _truncate(String text) {
  final oneLine = text.replaceAll('\n', ' ').trim();
  if (oneLine.length <= 100) return oneLine;
  return '${oneLine.substring(0, 100)}…';
}

final class _Report {
  int passed = 0;
  int failed = 0;
  int skipped = 0;
  final List<String> _failures = <String>[];

  void pass(String name, [String? detail]) {
    passed++;
    stdout.writeln('[PASS] $name${detail == null ? '' : ' — $detail'}');
  }

  void fail(String name, Object detail) {
    failed++;
    _failures.add(name);
    stdout.writeln('[FAIL] $name — $detail');
  }

  void skip(String name, String reason) {
    skipped++;
    stdout.writeln('[SKIP] $name — $reason');
  }

  String get summary {
    final failedList = _failures.isEmpty
        ? ''
        : ' (failed: ${_failures.join(', ')})';
    return 'passed=$passed failed=$failed skipped=$skipped$failedList';
  }
}
