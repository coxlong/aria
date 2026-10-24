import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/aria_colors.dart';
import '../../../../core/theme/aria_tokens.dart';
import '../../../../core/theme/aria_type.dart';
import '../../../../domain/session/agent_session.dart';
import '../../../../l10n/app_localizations.dart';

/// One choice from a flat list.
Future<String?> showOptionSheet({
  required BuildContext context,
  required String title,
  required List<SessionOption> options,
  required String? selectedId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final colors = context.ariaColors;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SheetTitle(title),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AriaSpacing.sm,
                  vertical: AriaSpacing.xs,
                ),
                children: <Widget>[
                  for (final option in options)
                    _ChoiceRow(
                      label: option.label,
                      selected: option.id == selectedId,
                      onTap: () => Navigator.of(context).pop(option.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AriaSpacing.xs),
            Divider(color: colors.border, height: 1),
          ],
        ),
      );
    },
  );
}

/// Models, with the reasoning effort one page deeper when the agent offers it.
///
/// Effort is never its own chip: it only means anything in relation to a model,
/// and one more control on a phone-width composer is one too many.
Future<({String? modelId, String? effortValue})?> showModelSheet({
  required BuildContext context,
  required SessionSurfaces surfaces,
}) {
  return showModalBottomSheet<({String? modelId, String? effortValue})>(
    context: context,
    showDragHandle: true,
    builder: (context) => _ModelSheet(surfaces: surfaces),
  );
}

class _ModelSheet extends StatefulWidget {
  const _ModelSheet({required this.surfaces});

  final SessionSurfaces surfaces;

  @override
  State<_ModelSheet> createState() => _ModelSheetState();
}

class _ModelSheetState extends State<_ModelSheet> {
  bool _efforts = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final surfaces = widget.surfaces;

    if (_efforts) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _SheetTitle(
              l10n.effort,
              onBack: () => setState(() => _efforts = false),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AriaSpacing.sm,
                  vertical: AriaSpacing.xs,
                ),
                children: <Widget>[
                  for (final option in surfaces.efforts)
                    _ChoiceRow(
                      label: option.label,
                      selected: option.id == surfaces.currentEffortValue,
                      onTap: () =>
                          Navigator.of(context)
                              .pop((modelId: null, effortValue: option.id)),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SheetTitle(l10n.model),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                horizontal: AriaSpacing.sm,
                vertical: AriaSpacing.xs,
              ),
              children: <Widget>[
                for (final option in surfaces.models)
                  _ChoiceRow(
                    label: option.label,
                    selected: option.id == surfaces.currentModelId,
                    onTap: () =>
                        Navigator.of(context)
                            .pop((modelId: option.id, effortValue: null)),
                  ),
                if (surfaces.hasEfforts)
                  _ChoiceRow(
                    label: l10n.effort,
                    trailing: surfaces.effortLabel,
                    selected: false,
                    onTap: () => setState(() => _efforts = true),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle(this.title, {this.onBack});

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

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;

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
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: type.ui.copyWith(
                    color: selected ? colors.primary : colors.text,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: type.caption.copyWith(color: colors.textMuted),
                ),
              if (selected) ...<Widget>[
                const SizedBox(width: AriaSpacing.xs),
                Icon(Icons.check_rounded, size: 18, color: colors.primary),
              ],
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AriaSpacing.xxs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
