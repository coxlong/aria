import 'package:material_ui/material_ui.dart';

import '../../../../domain/chat/chat_turn.dart';
import '../../../../domain/chat/work_step.dart';

/// The glyph a process row leads with: reasoning, prose, and tools must be
/// tellable apart before the row's text is read.
IconData iconForBlock(TurnBlock block) => switch (block) {
  ThoughtBlock() => Icons.psychology_alt_outlined,
  TextBlock() => Icons.chat_bubble_outline_rounded,
  ToolBlock(:final step) => iconForTool(step),
};

/// Tool calls have no kind field on the wire, so the title is all there is.
IconData iconForTool(WorkStep step) {
  final title = step.title.toLowerCase();
  if (title.contains('bash') || title.contains('command')) {
    return Icons.terminal_rounded;
  }
  if (title.contains('read')) return Icons.visibility_outlined;
  if (title.contains('write')) return Icons.note_add_outlined;
  if (title.contains('edit')) return Icons.edit_outlined;
  return Icons.build_outlined;
}
