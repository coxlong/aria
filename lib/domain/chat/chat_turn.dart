import 'work_step.dart';

/// One ordered piece of what the agent did during a turn.
sealed class TurnBlock {
  const TurnBlock();

  /// Stable key for list diffing.
  String get id;
}

/// Prose the agent emitted. Every prose block is part of the conversation;
/// prose is the only break between folded runs.
final class TextBlock extends TurnBlock {
  const TextBlock({required this.id, required this.text});

  @override
  final String id;

  final String text;
}

/// Reasoning the agent emitted. It lives inside a run, never in the thread.
final class ThoughtBlock extends TurnBlock {
  const ThoughtBlock({required this.id, required this.text});

  @override
  final String id;

  final String text;
}

/// A tool call, kept in place so later patches update the same row.
final class ToolBlock extends TurnBlock {
  const ToolBlock({required this.step});

  @override
  String get id => step.id;

  final WorkStep step;
}

/// One user request and everything the agent did in response.
class ChatTurn {
  const ChatTurn({
    required this.id,
    required this.userText,
    this.blocks = const <TurnBlock>[],
    this.running = false,
    this.stopped = false,
  });

  final String id;
  final String userText;
  final List<TurnBlock> blocks;
  final bool running;

  /// The person stopped this turn; what had arrived is kept.
  final bool stopped;

  ChatTurn copyWith({
    String? userText,
    List<TurnBlock>? blocks,
    bool? running,
    bool? stopped,
  }) => ChatTurn(
    id: id,
    userText: userText ?? this.userText,
    blocks: blocks ?? this.blocks,
    running: running ?? this.running,
    stopped: stopped ?? this.stopped,
  );

  /// Tool calls only, in wire order.
  List<WorkStep> get tools => <WorkStep>[
    for (final block in blocks)
      if (block is ToolBlock) block.step,
  ];

  /// The first tool still running, if any.
  WorkStep? get activeTool {
    for (final step in tools) {
      if (!step.status.isTerminal) return step;
    }
    return null;
  }
}
