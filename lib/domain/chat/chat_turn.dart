import 'work_step.dart';

/// One ordered piece of what the agent did during a turn.
sealed class TurnBlock {
  const TurnBlock();

  /// Stable key for list diffing.
  String get id;
}

/// Prose the agent emitted. Only the last one can be the answer; earlier ones
/// are intermediate commentary and belong to the work.
final class TextBlock extends TurnBlock {
  const TextBlock({required this.id, required this.text});

  @override
  final String id;

  final String text;
}

/// Reasoning the agent emitted. Never shown in the transcript itself.
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
final class ChatTurn {
  const ChatTurn({
    required this.id,
    required this.userText,
    this.blocks = const <TurnBlock>[],
    this.running = false,
    this.failed = false,
  });

  final String id;
  final String userText;
  final List<TurnBlock> blocks;
  final bool running;
  final bool failed;

  ChatTurn copyWith({
    String? userText,
    List<TurnBlock>? blocks,
    bool? running,
    bool? failed,
  }) => ChatTurn(
    id: id,
    userText: userText ?? this.userText,
    blocks: blocks ?? this.blocks,
    running: running ?? this.running,
    failed: failed ?? this.failed,
  );

  /// Index of the latest prose block, or null when the agent has only thought
  /// and called tools so far.
  int? get _answerIndex {
    for (var index = blocks.length - 1; index >= 0; index--) {
      if (blocks[index] is TextBlock) return index;
    }
    return null;
  }

  /// The newest prose is only the answer when nothing newer has happened: a
  /// tool or a thought after it means that text was commentary on the way.
  bool get _showsAnswer {
    final index = _answerIndex;
    if (index == null) return false;
    return !running || index == blocks.length - 1;
  }

  String get answerText {
    if (!_showsAnswer) return '';
    return (blocks[_answerIndex!] as TextBlock).text;
  }

  /// Everything that is not the answer: thinking, tool calls, intermediate
  /// prose. This is what the process pill counts.
  List<TurnBlock> get processBlocks => <TurnBlock>[
    for (var index = 0; index < blocks.length; index++)
      if (!(_showsAnswer && index == _answerIndex)) blocks[index],
  ];

  bool get hasProcess => processBlocks.isNotEmpty;

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

  /// True while the agent is emitting answer prose.
  bool get streamingAnswer =>
      running && _showsAnswer && (blocks.last as TextBlock).text.isNotEmpty;
}
