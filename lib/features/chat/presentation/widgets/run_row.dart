import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../domain/chat/work_step.dart';
import '../../../../l10n/app_localizations.dart';
import '../chat_stream.dart';
import 'run_sheet.dart';
import 'step_icon.dart';

/// One run in the thread: a quiet summary line, or its steps laid open when
/// there is no prose after them.
class RunView extends StatelessWidget {
  const RunView({super.key, required this.run});

  final RunItem run;

  @override
  Widget build(BuildContext context) {
    if (run.folded) return _RunFold(run: run);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final step in run.steps)
          RunRowTile(step: step, onTap: () => _openStep(context, step, run)),
      ],
    );
  }

  void _openStep(BuildContext context, RunStep step, RunItem run) {
    if (run.steps.length == 1) {
      showRunSheet(context, run: run);
      return;
    }
    showStepSheet(context, step: step);
  }
}

class _RunFold extends StatelessWidget {
  const _RunFold({required this.run});

  final RunItem run;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final failed = run.failedCount > 0;
    final label = runSummary(l10n, run);

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        borderRadius: AriaRadius.smAll,
        child: InkWell(
          onTap: () => showRunSheet(context, run: run),
          borderRadius: AriaRadius.smAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: ariaMinTarget),
            child: Padding(
              padding: const EdgeInsets.only(right: AriaSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 11,
                    color: failed ? colors.danger : colors.muted,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.ariaType.caption.copyWith(
                        fontSize: 12,
                        color: failed ? colors.danger : colors.muted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A step row, used both in the open tail of a turn and in the work log.
class RunRowTile extends StatelessWidget {
  const RunRowTile({
    super.key,
    required this.step,
    this.onTap,
    this.showChevron = false,
  });

  final RunStep step;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    final Widget icon;
    final String title;
    final String? target;
    final bool mutedTitle;
    final String? flag;
    final Color flagColor;

    switch (step) {
      case ThoughtStep(:final block):
        final line = _firstLine(block.text, 64);
        icon = Icon(Icons.auto_awesome_outlined, size: 15, color: colors.muted);
        title = l10n.thought;
        target = line.isEmpty ? null : line;
        mutedTitle = true;
        flag = null;
        flagColor = colors.muted;
      case ToolStep(:final step):
        icon = Icon(iconForTool(step), size: 15, color: colors.muted);
        title = step.title.trim().isEmpty ? l10n.toolCall : step.title.trim();
        target = stepTarget(step);
        mutedTitle = false;
        flag = stepFlag(l10n, step);
        flagColor = switch (step.status) {
          StepStatus.failed => colors.danger,
          StepStatus.running => colors.gold,
          _ => colors.muted,
        };
    }

    final titleColor = mutedTitle ? colors.muted : colors.ink2;
    return Material(
      color: Colors.transparent,
      borderRadius: AriaRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AriaRadius.smAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: <Widget>[
                SizedBox(width: 20, child: Center(child: icon)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: title,
                          style: type.run.copyWith(
                            color: titleColor,
                            fontWeight: mutedTitle
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                        if (target != null && target.isNotEmpty)
                          TextSpan(
                            text: ' · $target',
                            style: type.caption.copyWith(color: colors.muted),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (flag != null && flag.isNotEmpty) ...<Widget>[
                  const SizedBox(width: AriaSpacing.xs),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.4,
                    ),
                    child: Text(
                      flag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: type.caption.copyWith(color: flagColor),
                    ),
                  ),
                ],
                if (showChevron)
                  Padding(
                    padding: const EdgeInsets.only(left: AriaSpacing.xs),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 13,
                      color: colors.muted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _firstLine(String text, [int max = 60]) {
  final line = text.trim().split('\n').first.trim();
  if (line.length <= max) return line;
  return '${line.substring(0, max - 1)}…';
}
