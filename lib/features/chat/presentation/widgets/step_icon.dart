import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../domain/chat/work_step.dart';
import '../../../../l10n/app_localizations.dart';

/// The glyph a run row leads with. The protocol's tool category is the primary
/// signal; the title is the fallback for frames that do not carry one.
IconData iconForTool(WorkStep step) {
  switch (step.action) {
    case ToolAction.read:
      return Icons.description_outlined;
    case ToolAction.edit:
      return Icons.edit_outlined;
    case ToolAction.delete:
      return Icons.delete_outline_rounded;
    case ToolAction.move:
      return Icons.drive_file_move_outline;
    case ToolAction.search:
      return Icons.search_rounded;
    case ToolAction.execute:
      return Icons.terminal_rounded;
    case ToolAction.fetch:
      return Icons.language_rounded;
    case ToolAction.think:
      return Icons.auto_awesome_outlined;
    case ToolAction.other:
      break;
  }

  // Older frames may not carry a kind; fall back to the title.
  final title = step.title.toLowerCase();
  if (title.contains('bash') ||
      title.contains('command') ||
      title.contains('terminal') ||
      title.contains('run')) {
    return Icons.terminal_rounded;
  }
  if (title.contains('search') || title.contains('find')) {
    return Icons.search_rounded;
  }
  if (title.contains('read') ||
      title.contains('open') ||
      title.contains('view') ||
      title.contains('file')) {
    return Icons.description_outlined;
  }
  if (title.contains('write') ||
      title.contains('edit') ||
      title.contains('patch') ||
      title.contains('create')) {
    return Icons.edit_outlined;
  }
  if (title.contains('verify') ||
      title.contains('check') ||
      title.contains('test') ||
      title.contains('lint')) {
    return Icons.shield_outlined;
  }
  if (title.contains('fetch') || title.contains('web')) {
    return Icons.language_rounded;
  }
  if (title.contains('delete') || title.contains('remove')) {
    return Icons.delete_outline_rounded;
  }
  if (title.contains('folder') || title.contains('directory')) {
    return Icons.folder_outlined;
  }
  if (title.contains('读取') || title.contains('查看')) {
    return Icons.description_outlined;
  }
  if (title.contains('写') || title.contains('改') || title.contains('编辑')) {
    return Icons.edit_outlined;
  }
  if (title.contains('搜索') || title.contains('查找')) {
    return Icons.search_rounded;
  }
  if (title.contains('运行') || title.contains('命令') || title.contains('执行')) {
    return Icons.terminal_rounded;
  }
  if (title.contains('检查') || title.contains('核对') || title.contains('测试')) {
    return Icons.shield_outlined;
  }
  if (title.contains('删除')) return Icons.delete_outline_rounded;
  return Icons.handyman_outlined;
}

/// The mark that follows a tool row.
class StepMark extends StatelessWidget {
  const StepMark({super.key, required this.status});

  final StepStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final l10n = AppLocalizations.of(context);
    final Widget mark = switch (status) {
      StepStatus.running => const _RunningMark(),
      StepStatus.completed => Icon(
        Icons.check_rounded,
        size: 15,
        color: colors.ink2,
        semanticLabel: l10n.statusDone,
      ),
      StepStatus.failed => Icon(
        Icons.close_rounded,
        size: 15,
        color: colors.danger,
        semanticLabel: l10n.statusFailed,
      ),
      StepStatus.pending => Icon(
        Icons.schedule_rounded,
        size: 14,
        color: colors.muted,
        semanticLabel: l10n.statusPending,
      ),
    };
    return SizedBox(width: 18, height: 18, child: Center(child: mark));
  }
}

class _RunningMark extends StatelessWidget {
  const _RunningMark();

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.goldFill,
        boxShadow: <BoxShadow>[
          BoxShadow(color: colors.goldGlow, blurRadius: 10),
        ],
      ),
    );
  }
}
