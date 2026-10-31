import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../core/widgets/aria_sheet.dart';
import '../../../../domain/session/agent_session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../connection/application/agent_manager.dart';

/// The one place model, effort and mode are chosen.
///
/// Model and its reasoning effort read as one unit in the header; the sheet
/// keeps them together but gives each its own row of choices.
Future<void> showModelSheet(BuildContext context) {
  return showAriaSheet<void>(
    context: context,
    builder: (context) => const _ModelSheet(),
  );
}

class _ModelSheet extends ConsumerWidget {
  const _ModelSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final manager = ref.watch(agentManagerProvider);
    final sessionRef = manager.activeSessionRef;
    final surfaces = manager.activeSession?.surfaces ?? SessionSurfaces.none;
    final notifier = ref.read(agentManagerProvider.notifier);

    return AriaSheet(
      title: l10n.modelEffortMode,
      onClose: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AriaSection(
            title: l10n.model,
            child: surfaces.hasModels
                ? Column(
                    children: <Widget>[
                      for (final option in surfaces.models) ...<Widget>[
                        _PickTile(
                          label: option.label,
                          selected: option.id == surfaces.currentModelId,
                          onTap: () => unawaited(
                            sessionRef == null
                                ? Future<void>.value()
                                : notifier.selectModel(sessionRef, option.id),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  )
                : AriaNote(l10n.noModels),
          ),
          const SizedBox(height: AriaSpacing.md),
          AriaSection(
            title: l10n.reasoningEffort,
            contextLabel: surfaces.modelLabel,
            child: surfaces.hasEfforts
                ? _ChoiceGrid(
                    options: surfaces.efforts,
                    selectedId: surfaces.currentEffortValue,
                    onPick: (id) => unawaited(
                      sessionRef == null
                          ? Future<void>.value()
                          : notifier.selectEffort(sessionRef, id),
                    ),
                  )
                : AriaNote(l10n.noEfforts),
          ),
          const SizedBox(height: AriaSpacing.md),
          AriaSection(
            title: l10n.mode,
            child: surfaces.hasModes
                ? _ChoiceGrid(
                    options: surfaces.modes,
                    selectedId: surfaces.currentModeId,
                    onPick: (id) => unawaited(
                      sessionRef == null
                          ? Future<void>.value()
                          : notifier.selectMode(sessionRef, id),
                    ),
                  )
                : AriaNote(l10n.noModes),
          ),
          const SizedBox(height: AriaSpacing.md),
          Text(
            l10n.appliesNextTurn,
            style: context.ariaType.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
      foot: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.done),
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Material(
      color: selected ? colors.key : colors.panel,
      borderRadius: AriaRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AriaRadius.lgAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: context.ariaType.label.copyWith(
                      color: selected ? colors.keyInk : colors.ink,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, size: 16, color: colors.keyInk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.options,
    required this.selectedId,
    required this.onPick,
  });

  final List<SessionOption> options;
  final String? selectedId;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final half = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (var index = 0; index < options.length; index++)
              SizedBox(
                width: index == options.length - 1 && options.length.isOdd
                    ? constraints.maxWidth
                    : half,
                child: _ChoiceTile(
                  label: options[index].label,
                  selected: options[index].id == selectedId,
                  onTap: () => onPick(options[index].id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return Material(
      color: selected ? colors.key : colors.panel,
      borderRadius: AriaRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AriaRadius.lgAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 46),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.ariaType.small.copyWith(
                      color: selected ? colors.keyInk : colors.ink2,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, size: 14, color: colors.keyInk),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
