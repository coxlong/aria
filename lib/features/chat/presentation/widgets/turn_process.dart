import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../domain/chat/chat_turn.dart';
import '../../../../domain/chat/work_step.dart';
import '../../../../l10n/app_localizations.dart';
import 'process_sheet.dart';
import 'step_icon.dart';
import 'step_preview.dart';

/// What the turn is doing, in the transcript itself.
///
/// While a turn runs this is a small live card: the step executing now and the
/// last couple of steps behind it, so progress is readable without opening
/// anything. Once the turn ends it folds back to one quiet line, so a finished
/// transcript stays a record instead of a wall of status.
///
/// Nothing here claims to know how far along the work is. The protocol reports
/// no totals and no timestamps, so the card shows what is true — what is
/// running, and what already finished.
class TurnProcess extends StatelessWidget {
  const TurnProcess({super.key, required this.turn});

  final ChatTurn turn;

  @override
  Widget build(BuildContext context) {
    return switch (turn.running) {
      true => _RunningWork(turn: turn),
      false => _FinishedLine(turn: turn),
    };
  }
}

class _RunningWork extends StatelessWidget {
  const _RunningWork({required this.turn});

  final ChatTurn turn;

  /// How many finished steps stay in view. The card is a glance, not the log.
  static const int _keptSteps = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    final active = turn.activeTool;
    final last = turn.blocks.isEmpty ? null : turn.blocks.last;

    // The headline answers "what is happening now", so a concrete step beats a
    // generic label whenever one is available.
    final IconData icon;
    final String title;
    if (active != null) {
      final stepTitle = active.title.trim();
      icon = iconForTool(active);
      title = stepTitle.isEmpty ? l10n.toolCall : stepTitle;
    } else if (last is ThoughtBlock && last.text.trim().isNotEmpty) {
      icon = Icons.psychology_alt_outlined;
      title = firstLineOf(last.text, maxLength: 90);
    } else if (last is TextBlock && last.text.trim().isNotEmpty) {
      icon = Icons.chat_bubble_outline_rounded;
      title = l10n.processAnswering;
    } else {
      icon = Icons.psychology_alt_outlined;
      title = l10n.processThinking;
    }

    final done = <WorkStep>[
      for (final step in turn.tools)
        if (step.status.isTerminal && step.title.trim().isNotEmpty) step,
    ];
    final kept = done.length <= _keptSteps
        ? done
        : done.sublist(done.length - _keptSteps);

    return Material(
      color: colors.surface,
      borderRadius: AriaRadius.lgAll,
      child: InkWell(
        onTap: () => showProcessSheet(context, turn),
        borderRadius: AriaRadius.lgAll,
        child: Container(
          constraints: const BoxConstraints(minHeight: ariaMinTarget),
          padding: const EdgeInsets.fromLTRB(
            AriaSpacing.sm,
            AriaSpacing.xs,
            AriaSpacing.xs,
            AriaSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: AriaRadius.lgAll,
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _Pulse(icon: icon, color: colors.primary),
                  const SizedBox(width: AriaSpacing.sm),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: type.ui.copyWith(color: colors.text),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: colors.textMuted,
                  ),
                ],
              ),
              for (final step in kept) _DoneRow(step: step),
            ],
          ),
        ),
      ),
    );
  }
}

/// A step that already finished, kept in view so the path so far is readable.
class _DoneRow extends StatelessWidget {
  const _DoneRow({required this.step});

  final WorkStep step;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final failed = step.status == StepStatus.failed;
    return Padding(
      padding: const EdgeInsets.only(
        left: 30,
        top: AriaSpacing.xxs,
        right: AriaSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            failed ? Icons.close_rounded : Icons.check_rounded,
            size: 14,
            color: failed ? colors.error : colors.success,
          ),
          const SizedBox(width: AriaSpacing.xs),
          Expanded(
            child: Text(
              step.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.ariaType.caption.copyWith(
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A quiet mark that something is moving, without inventing a percentage.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true, min: 0.45);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: FadeTransition(
        opacity: _controller,
        child: Icon(widget.icon, size: 18, color: widget.color),
      ),
    );
  }
}

/// The one quiet line a finished turn keeps.
class _FinishedLine extends StatelessWidget {
  const _FinishedLine({required this.turn});

  final ChatTurn turn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final tools = turn.tools;
    final failed = tools.any((step) => step.status == StepStatus.failed);
    final color = failed ? colors.error : colors.textMuted;

    final IconData icon;
    final String label;
    if (tools.isEmpty) {
      icon = Icons.psychology_alt_outlined;
      label = l10n.thinkingProcess;
    } else {
      icon = failed ? Icons.error_outline_rounded : Icons.check_rounded;
      label = l10n.processDone(tools.length);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: colors.surface,
        borderRadius: AriaRadius.pillAll,
        child: InkWell(
          borderRadius: AriaRadius.pillAll,
          onTap: () => showProcessSheet(context, turn),
          child: Container(
            constraints: const BoxConstraints(minHeight: 32),
            padding: const EdgeInsets.symmetric(
              horizontal: AriaSpacing.sm,
              vertical: AriaSpacing.xxs,
            ),
            decoration: BoxDecoration(
              borderRadius: AriaRadius.pillAll,
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AriaSpacing.xs),
                Text(label, style: type.ui.copyWith(color: color)),
                const SizedBox(width: AriaSpacing.xxs),
                Icon(Icons.chevron_right_rounded, size: 16, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
