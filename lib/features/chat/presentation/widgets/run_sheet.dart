import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../core/widgets/aria_sheet.dart';
import '../../../../domain/chat/work_step.dart';
import '../../../../l10n/app_localizations.dart';
import '../chat_stream.dart';
import 'run_row.dart';
import 'step_icon.dart';

/// Opens a run's work log.
///
/// A one-step run has nothing to list, so its summary opens the step itself.
Future<void> showRunSheet(BuildContext context, {required RunItem run}) {
  return showAriaSheet<void>(
    context: context,
    builder: (context) => _RunSheet(run: run),
  );
}

/// Opens one step on its own, without a work log behind it.
Future<void> showStepSheet(BuildContext context, {required RunStep step}) {
  return showAriaSheet<void>(
    context: context,
    builder: (context) => _StepSheet(step: step),
  );
}

class _RunSheet extends StatefulWidget {
  const _RunSheet({required this.run});

  final RunItem run;

  @override
  State<_RunSheet> createState() => _RunSheetState();
}

class _RunSheetState extends State<_RunSheet> {
  RunStep? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.run.steps.length == 1) _selected = widget.run.steps.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selected;
    final single = widget.run.steps.length == 1;
    final canBack = selected != null && !single;

    if (selected != null) {
      return _StepSheet(
        step: selected,
        onBack: canBack ? () => setState(() => _selected = null) : null,
      );
    }

    return AriaSheet(
      title: runHead(l10n, widget.run),
      onClose: () => Navigator.of(context).pop(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: AriaSpacing.xxs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (var index = 0; index < widget.run.steps.length; index++) ...[
              if (index > 0) const SizedBox(height: AriaSpacing.xxs),
              RunRowTile(
                key: ValueKey<String>(widget.run.steps[index].id),
                step: widget.run.steps[index],
                onTap: () =>
                    setState(() => _selected = widget.run.steps[index]),
              ),
            ],
          ],
        ),
      ),
      foot: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ),
    );
  }
}

class _StepSheet extends StatelessWidget {
  const _StepSheet({required this.step, this.onBack});

  final RunStep step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    final String title;
    final Widget body;

    switch (step) {
      case ThoughtStep(:final block):
        title = _firstLine(block.text, 32).isEmpty
            ? l10n.thought
            : _firstLine(block.text, 32);
        body = SelectableText(
          block.text,
          style: type.quote.copyWith(color: colors.ink2),
        );
      case ToolStep(:final step):
        final target = stepTarget(step);
        title =
            (step.title.trim().isEmpty ? l10n.toolCall : step.title.trim()) +
            (target == null ? '' : ' · $target');
        body = _StepDetail(step: step);
    }

    return AriaSheet(
      title: title,
      onBack: onBack,
      onClose: () => Navigator.of(context).pop(),
      body: body,
      foot: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ),
    );
  }
}

class _StepDetail extends StatelessWidget {
  const _StepDetail({required this.step});

  final WorkStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final status = step.status;
    final failed = status == StepStatus.failed;

    final input = _clean(step.input);
    final output = _clean(step.output);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            StepMark(status: status),
            const SizedBox(width: AriaSpacing.xs),
            Text(
              statusLabel(l10n, status),
              style: context.ariaType.caption.copyWith(color: colors.muted),
            ),
          ],
        ),
        const SizedBox(height: AriaSpacing.md),
        if (input != null) _CodeSection(label: l10n.stepInput, value: input),
        if (output != null && !failed)
          _CodeSection(label: l10n.stepOutput, value: output),
        if (failed)
          _ErrorSection(
            label: l10n.stepError,
            value: output ?? _clean(step.detail) ?? l10n.statusFailed,
          ),
      ],
    );
  }

  static String? _clean(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class _CodeSection extends StatelessWidget {
  const _CodeSection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AriaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            label,
            style: context.ariaType.caption.copyWith(
              color: colors.muted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AriaSpacing.xs),
          _CodeBlock(value: value),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: colors.panelDeep,
        borderRadius: AriaRadius.mdAll,
      ),
      child: SelectableText(
        value,
        style: context.ariaType.code.copyWith(
          color: colors.ink2,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label,
          style: context.ariaType.caption.copyWith(
            color: colors.muted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AriaSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: colors.dangerSoft,
            borderRadius: AriaRadius.mdAll,
          ),
          child: SelectableText(
            value,
            style: context.ariaType.small.copyWith(color: colors.danger),
          ),
        ),
      ],
    );
  }
}

String _firstLine(String text, int max) {
  final line = text.trim().split('\n').first.trim();
  if (line.length <= max) return line;
  return '${line.substring(0, max - 1)}…';
}
