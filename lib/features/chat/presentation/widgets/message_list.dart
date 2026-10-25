import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../core/widgets/aria_markdown.dart';
import '../../../../domain/chat/chat_turn.dart';
import '../../../../domain/chat/work_step.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/chat_view.dart';
import 'process_sheet.dart';
import 'step_icon.dart';

/// The conversation is a record, not a control panel: exactly one stream, in
/// chronological order.
class MessageList extends StatefulWidget {
  const MessageList({super.key, required this.view});

  final ChatView view;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Streaming may grow the page, but it must never yank the reader. Follow
  /// only when the reader was already at the bottom.
  bool get _isAtBottom {
    if (!_controller.hasClients) return true;
    final position = _controller.position;
    return position.maxScrollExtent - position.pixels <= 80;
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isAtBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final turns = widget.view.turns;

    if (turns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AriaSpacing.lg),
          child: Text(
            l10n.composerHint,
            textAlign: TextAlign.center,
            style: context.ariaType.body.copyWith(color: colors.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(
        AriaSpacing.md,
        AriaSpacing.md,
        AriaSpacing.md,
        AriaSpacing.lg,
      ),
      itemCount: turns.length,
      itemBuilder: (context, index) =>
          _TurnView(key: ValueKey<String>(turns[index].id), turn: turns[index]),
    );
  }
}

class _TurnView extends StatelessWidget {
  const _TurnView({super.key, required this.turn});

  final ChatTurn turn;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;

    return Padding(
      padding: const EdgeInsets.only(bottom: AriaSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (turn.userText.trim().isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AriaSpacing.userMessageMax,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AriaSpacing.md,
                    vertical: AriaSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.inset,
                    borderRadius: AriaRadius.xlAll,
                  ),
                  child: SelectableText(
                    turn.userText,
                    style: type.body.copyWith(color: colors.text),
                  ),
                ),
              ),
            ),
          if (turn.userText.trim().isNotEmpty)
            const SizedBox(height: AriaSpacing.sm),
          if (turn.hasProcess)
            Align(
              alignment: Alignment.centerLeft,
              child: ProcessPill(turn: turn),
            ),
          if (turn.hasProcess && turn.answerText.isNotEmpty)
            const SizedBox(height: AriaSpacing.xs),
          if (turn.answerText.isNotEmpty)
            AriaMarkdown(turn.answerText, streaming: turn.streamingAnswer),
          if (turn.awaitingFirstOutput) const _WaitingDots(),
        ],
      ),
    );
  }
}

/// A quiet indicator that the agent is working but has not produced anything
/// visible yet.
class _WaitingDots extends StatelessWidget {
  const _WaitingDots();

  @override
  Widget build(BuildContext context) {
    final color = context.ariaColors.textMuted;
    return Padding(
      padding: const EdgeInsets.only(top: AriaSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var index = 0; index < 3; index++)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The one quiet line under Aria's reply: what it did, tappable to expand.
class ProcessPill extends StatelessWidget {
  const ProcessPill({super.key, required this.turn});

  final ChatTurn turn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final active = turn.capsuleActive;
    final tools = turn.tools;

    final String label;
    // An unfinished step is only "running" while the turn is: a cancelled turn
    // leaves its last tool open, and the pill must not keep saying it executes.
    final WorkStep? running = turn.running ? turn.activeTool : null;
    if (running != null) {
      final index = tools.indexOf(running) + 1;
      label = l10n.processRunning(index);
    } else if (tools.isNotEmpty) {
      label = l10n.processDone(tools.length);
    } else {
      label = l10n.thinkingProcess;
    }

    final color = active ? colors.primary : colors.textMuted;

    return Material(
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
              Icon(
                running != null
                    ? iconForTool(running)
                    : (tools.isEmpty
                          ? Icons.psychology_alt_outlined
                          : iconForTool(tools.last)),
                size: 16,
                color: color,
              ),
              const SizedBox(width: AriaSpacing.xs),
              Text(
                label,
                style: type.ui.copyWith(
                  color: color,
                  fontFeatures: AriaType.tabularFigures,
                ),
              ),
              const SizedBox(width: AriaSpacing.xxs),
              Icon(Icons.chevron_right_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
