import 'dart:convert';

import '../../../../domain/chat/chat_turn.dart';
import '../../../../domain/chat/work_step.dart';
import '../../../../l10n/app_localizations.dart';

/// The thread as the design sees it: one stream where prose is the only break.
///
/// Consecutive thinking and tool calls merge into a run. A run followed by
/// prose folds to one line; the run at the end of a turn stays open, one row
/// per step. User messages and turn endings are hard boundaries.
sealed class ChatItem {
  const ChatItem();
}

final class UserItem extends ChatItem {
  const UserItem(this.text);

  final String text;
}

final class ProseItem extends ChatItem {
  const ProseItem({
    required this.id,
    required this.text,
    required this.streaming,
  });

  final String id;
  final String text;
  final bool streaming;
}

final class NoticeItem extends ChatItem {
  const NoticeItem.stopped();
}

final class RunItem extends ChatItem {
  const RunItem({
    required this.id,
    required this.steps,
    required this.folded,
    required this.running,
  });

  final String id;
  final List<RunStep> steps;
  final bool folded;
  final bool running;

  int get toolCount => steps.whereType<ToolStep>().length;

  int get thoughtCount => steps.whereType<ThoughtStep>().length;

  int get failedCount => steps
      .whereType<ToolStep>()
      .where((step) => step.block.step.status == StepStatus.failed)
      .length;
}

sealed class RunStep {
  const RunStep();

  String get id;
}

final class ThoughtStep extends RunStep {
  const ThoughtStep(this.block);

  final ThoughtBlock block;

  @override
  String get id => block.id;
}

final class ToolStep extends RunStep {
  const ToolStep(this.block);

  final ToolBlock block;

  @override
  String get id => block.id;

  WorkStep get step => block.step;
}

/// Builds the ordered stream for a conversation.
List<ChatItem> buildChatStream(List<ChatTurn> turns) {
  final items = <ChatItem>[];

  for (final turn in turns) {
    if (turn.userText.trim().isNotEmpty) {
      items.add(UserItem(turn.userText));
    }

    List<RunStep>? run;

    void flush({required bool folded}) {
      final steps = run;
      if (steps == null || steps.isEmpty) {
        run = null;
        return;
      }
      items.add(
        RunItem(
          id: _runId(steps),
          steps: List<RunStep>.unmodifiable(steps),
          folded: folded,
          running: turn.running,
        ),
      );
      run = null;
    }

    for (var index = 0; index < turn.blocks.length; index++) {
      final block = turn.blocks[index];
      switch (block) {
        case TextBlock():
          flush(folded: true);
          items.add(
            ProseItem(
              id: block.id,
              text: block.text,
              streaming:
                  turn.running &&
                  index == turn.blocks.length - 1 &&
                  block.text.trim().isNotEmpty,
            ),
          );
        case ThoughtBlock():
          run ??= <RunStep>[];
          run!.add(ThoughtStep(block));
        case ToolBlock():
          run ??= <RunStep>[];
          run!.add(ToolStep(block));
      }
    }

    // No prose after it: the run stays open at the end of the turn.
    flush(folded: false);

    if (turn.stopped) {
      items.add(const NoticeItem.stopped());
    }
  }

  return items;
}

String _runId(List<RunStep> steps) {
  final first = steps.first;
  return switch (first) {
    ThoughtStep() => 't:${first.id}',
    ToolStep() => 'a:${first.id}',
  };
}

String runFailLabel(AppLocalizations l10n, RunItem run) =>
    run.failedCount == 0 ? '' : l10n.failedCountSuffix(run.failedCount);

/// The line a folded run shows: what it did first; the count is the footnote.
String runSummary(AppLocalizations l10n, RunItem run) {
  if (run.steps.length == 1) {
    final step = run.steps.first;
    return switch (step) {
      ThoughtStep() =>
        _firstLine(step.block.text, 46).isEmpty
            ? l10n.thought
            : _firstLine(step.block.text, 46),
      ToolStep() =>
        _titleOf(l10n, step.step) +
            (step.step.status == StepStatus.failed ? l10n.failedSuffix : ''),
    };
  }

  final names = <String>[];
  for (final step in run.steps.whereType<ToolStep>()) {
    final name = _titleOf(l10n, step.step);
    if (!names.contains(name)) names.add(name);
  }
  if (names.isEmpty) return l10n.thoughtsCount(run.thoughtCount);

  final count = l10n.stepsCount(run.steps.length);
  final shown = names.take(2).join(l10n.listSeparator);
  final tail = names.length > 2
      ? l10n.andMoreSteps(run.steps.length)
      : ' · $count';
  return shown + tail + runFailLabel(l10n, run);
}

/// The header of a run's work log; the body has room for the rows.
String runHead(AppLocalizations l10n, RunItem run) => runSummary(l10n, run);

/// The short thing a tool acted on, when the call carried one.
///
/// ACP has no first-class `target`; the closest honest source is the call's
/// own input. Reading a path or command from it is still the real value, not a
/// guess about what the tool did.
String? stepTarget(WorkStep step) {
  final input = step.input;
  if (input != null && input.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(input);
      if (decoded is Map<String, Object?>) {
        for (final key in const <String>[
          'file_path',
          'filePath',
          'path',
          'notebook_path',
          'command',
          'query',
          'pattern',
          'url',
          'target',
        ]) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return _firstLine(value, 40);
          }
        }
      }
    } on FormatException {
      // Not JSON; fall through to the content text.
    }
  }
  final detail = step.detail?.trim();
  if (detail == null || detail.isEmpty) return null;
  final line = _firstLine(detail, 40);
  return line.length <= 40 && !detail.contains('\n') ? line : null;
}

/// The note a step row shows on the right; only exceptions get one.
String? stepFlag(AppLocalizations l10n, WorkStep step) {
  switch (step.status) {
    case StepStatus.failed:
      final line = step.detail ?? step.output;
      final text = line == null ? '' : _firstLine(line, 40);
      return text.isEmpty ? l10n.statusFailed : text;
    case StepStatus.running:
      return l10n.statusRunning;
    case StepStatus.pending:
      return l10n.statusPending;
    case StepStatus.completed:
      return null;
  }
}

String _titleOf(AppLocalizations l10n, WorkStep step) =>
    step.title.trim().isEmpty ? l10n.toolCall : step.title.trim();

String _firstLine(String text, [int max = 60]) {
  final line = text.trim().split('\n').first.trim();
  if (line.length <= max) return line;
  return '${line.substring(0, max - 1)}…';
}

String statusLabel(AppLocalizations l10n, StepStatus status) =>
    switch (status) {
      StepStatus.pending => l10n.statusPending,
      StepStatus.running => l10n.statusRunning,
      StepStatus.completed => l10n.statusDone,
      StepStatus.failed => l10n.statusFailed,
    };
