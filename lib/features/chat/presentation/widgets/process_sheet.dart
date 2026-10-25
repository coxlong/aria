import 'package:material_ui/material_ui.dart';

import '../../../../core/format/aria_format.dart';
import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../core/widgets/aria_markdown.dart';
import '../../../../domain/chat/chat_turn.dart';
import '../../../../domain/chat/work_step.dart';
import '../../../../l10n/app_localizations.dart';
import 'step_icon.dart';

/// Shows what the agent did during one turn.
///
/// A list first; tapping a row opens that step's inputs and outputs. Nothing
/// here is protocol-shaped: a step is a title, a state, and two blobs of text.
Future<void> showProcessSheet(BuildContext context, ChatTurn turn) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, controller) =>
          _ProcessSheet(turn: turn, controller: controller),
    ),
  );
}

class _ProcessSheet extends StatefulWidget {
  const _ProcessSheet({required this.turn, required this.controller});

  final ChatTurn turn;
  final ScrollController controller;

  @override
  State<_ProcessSheet> createState() => _ProcessSheetState();
}

class _ProcessSheetState extends State<_ProcessSheet> {
  _Selection? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final selected = _selected;

    if (selected != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Header(
            title: selected.title,
            onBack: () => setState(() => _selected = null),
          ),
          Expanded(
            child: ListView(
              controller: widget.controller,
              padding: const EdgeInsets.fromLTRB(
                AriaSpacing.lg,
                0,
                AriaSpacing.lg,
                AriaSpacing.lg,
              ),
              children: <Widget>[
                switch (selected) {
                  _StepSelection(:final step) => _StepDetail(step: step),
                  _TextSelection(:final text) => AriaMarkdown(text),
                },
              ],
            ),
          ),
        ],
      );
    }

    final steps = widget.turn.processBlocks;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Header(title: l10n.processTitle),
        Expanded(
          child: steps.isEmpty
              ? Center(
                  child: Text(
                    l10n.processEmpty,
                    style: context.ariaType.ui.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: widget.controller,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AriaSpacing.sm,
                  ),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final block = steps[index];
                    return switch (block) {
                      ToolBlock(:final step) => _StepRow(
                        title: _titleOf(step, l10n),
                        icon: iconForTool(step),
                        status: step.status,
                        onTap: () => setState(
                          () => _selected = _StepSelection(
                            _titleOf(step, l10n),
                            step,
                          ),
                        ),
                      ),
                      // Reasoning is worth reading in the list itself: a row
                      // of identical "Thinking" labels says nothing about
                      // what was actually considered.
                      ThoughtBlock(:final text) => _StepRow(
                        title: _previewOf(text, l10n.thinkingProcess),
                        icon: iconForBlock(block),
                        onTap: () => setState(
                          () => _selected = _TextSelection(
                            _previewOf(text, l10n.thinkingProcess),
                            text,
                          ),
                        ),
                      ),
                      // Intermediate prose is part of the work, but the row
                      // only has room for its first line; the page behind it
                      // is where the rest of the text lives.
                      TextBlock(:final text) => _StepRow(
                        title: _firstLine(text),
                        icon: iconForBlock(block),
                        onTap: () => setState(
                          () => _selected = _TextSelection(
                            _firstLine(text),
                            text,
                          ),
                        ),
                      ),
                    };
                  },
                ),
        ),
      ],
    );
  }

  String _titleOf(WorkStep step, AppLocalizations l10n) =>
      step.title.trim().isNotEmpty ? step.title : l10n.toolCall;

  static String _previewOf(String text, String fallback) {
    final line = _firstLine(text);
    return line.isEmpty ? fallback : line;
  }

  /// A row is a preview: one short line, with the page behind it holding the
  /// rest.
  static String _firstLine(String text) {
    final line = text.trim().split('\n').first;
    return line.length <= 60 ? line : '${line.substring(0, 57)}…';
  }
}

/// The second page: a tool with its inputs and outputs, or a block of text.
///
/// Reasoning and intermediate prose used to be built into a blank [WorkStep],
/// which is why tapping them opened an empty page.
sealed class _Selection {
  const _Selection(this.title);

  final String title;
}

final class _StepSelection extends _Selection {
  const _StepSelection(super.title, this.step);

  final WorkStep step;
}

final class _TextSelection extends _Selection {
  const _TextSelection(super.title, this.text);

  final String text;
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: AriaSpacing.xxl,
            child: onBack == null
                ? null
                : IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: colors.textMuted,
                  ),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.ariaType.title.copyWith(color: colors.text),
            ),
          ),
          const SizedBox(width: AriaSpacing.xxl),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.title,
    required this.icon,
    this.status,
    this.onTap,
  });

  final String title;

  /// What the row is — reasoning, prose, or a tool — so rows are not told
  /// apart by reading them.
  final IconData icon;

  /// Tools carry a state; reasoning and prose are just content.
  final StepStatus? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final status = this.status;
    return InkWell(
      onTap: onTap,
      borderRadius: AriaRadius.mdAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: ariaMinTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AriaSpacing.sm,
            vertical: AriaSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 18, color: _kindColor(colors, status)),
              const SizedBox(width: AriaSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.ariaType.ui.copyWith(color: colors.text),
                ),
              ),
              if (status != null) _StatusMark(status: status),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _kindColor(AriaColors colors, StepStatus? status) => switch (status) {
    StepStatus.running => colors.primary,
    StepStatus.failed => colors.error,
    _ => colors.textMuted,
  };
}

class _StatusMark extends StatelessWidget {
  const _StatusMark({required this.status});

  final StepStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return switch (status) {
      StepStatus.completed => Icon(
        Icons.check_rounded,
        size: 16,
        color: colors.success,
      ),
      StepStatus.failed => Icon(
        Icons.close_rounded,
        size: 16,
        color: colors.error,
      ),
      StepStatus.running => SizedBox(
        width: 16,
        height: 16,
        child: Center(
          child: SizedBox(
            width: 7,
            height: 7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
      StepStatus.pending => Icon(
        Icons.circle_outlined,
        size: 14,
        color: colors.textMuted,
      ),
    };
  }
}

class _StepDetail extends StatelessWidget {
  const _StepDetail({required this.step});

  final WorkStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;

    final duration = step.duration;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (duration != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AriaSpacing.sm),
            child: Text(
              formatDuration(l10n, duration),
              style: context.ariaType.caption.copyWith(
                color: colors.textMuted,
                fontFeatures: AriaType.tabularFigures,
              ),
            ),
          ),
        // Inputs are structured data, so they stay monospaced; outputs and
        // notes are usually prose, so they get rendered.
        _Block(label: l10n.stepInput, value: step.input),
        _Block(label: l10n.stepOutput, value: step.output, markdown: true),
        _Block(label: l10n.details, value: step.detail, markdown: true),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.label,
    required this.value,
    this.markdown = false,
  });

  final String label;
  final String? value;
  final bool markdown;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    final colors = context.ariaColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AriaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: context.ariaType.caption.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: AriaSpacing.xxs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AriaSpacing.sm),
            decoration: BoxDecoration(
              color: markdown ? Colors.transparent : colors.inset,
              borderRadius: AriaRadius.mdAll,
              border: markdown ? null : Border.all(color: colors.border),
            ),
            child: markdown
                ? AriaMarkdown(value)
                : SelectableText(
                    value,
                    style: context.ariaType.code.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
