import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_step.freezed.dart';

/// The state of one unit of work.
enum StepStatus {
  pending,
  running,
  completed,
  failed;

  bool get isTerminal =>
      this == StepStatus.completed || this == StepStatus.failed;
}

/// What kind of work a step represents.
enum StepKind {
  /// A tool the agent called.
  tool,

  /// The agent thinking out loud. Never shown in the transcript itself.
  thought,
}

/// The protocol's tool category, normalised so the interface can pick a glyph
/// without reading the tool's title.
enum ToolAction {
  read,
  edit,
  delete,
  move,
  search,
  execute,
  fetch,
  think,
  other,
}

/// One row in the process sheet.
@freezed
abstract class WorkStep with _$WorkStep {
  const factory WorkStep({
    required String id,
    required String title,
    required StepStatus status,
    @Default(StepKind.tool) StepKind kind,
    @Default(ToolAction.other) ToolAction action,
    String? detail,
    String? input,
    String? output,
    DateTime? startedAt,
    DateTime? endedAt,
  }) = _WorkStep;

  const WorkStep._();

  /// Only shown when a step actually ran long enough to be worth a duration.
  Duration? get duration {
    final start = startedAt;
    final end = endedAt;
    if (start == null || end == null) return null;
    final elapsed = end.difference(start);
    return elapsed.inSeconds < 1 ? null : elapsed;
  }
}
