import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/format/aria_format.dart';
import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../core/widgets/aria_sheet.dart';
import '../../../domain/session/agent_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/application/agent_manager.dart';

/// Finds a conversation by title or working directory.
Future<String?> showSearchSheet(BuildContext context) {
  return showAriaSheet<String>(
    context: context,
    builder: (context) => const _SearchSheet(),
  );
}

class _SearchSheet extends ConsumerStatefulWidget {
  const _SearchSheet();

  @override
  ConsumerState<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends ConsumerState<_SearchSheet> {
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final sessions = ref.watch(
      agentManagerProvider.select(
        (state) => state.activeAgent?.sessions ?? const <AgentSessionSummary>[],
      ),
    );
    final query = _query.text.trim().toLowerCase();
    final results = query.isEmpty
        ? sessions
        : sessions
              .where(
                (session) =>
                    session.title.toLowerCase().contains(query) ||
                    session.cwd.toLowerCase().contains(query),
              )
              .toList(growable: false);

    return AriaSheet(
      title: l10n.findConversation,
      onClose: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.searchConversations,
            style: context.ariaType.caption.copyWith(
              color: colors.ink2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _query,
            autofocus: true,
            textInputAction: TextInputAction.search,
            style: context.ariaType.body.copyWith(color: colors.ink),
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 18,
                color: colors.muted,
              ),
            ),
          ),
          const SizedBox(height: AriaSpacing.md),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AriaSpacing.lg),
              child: Text(
                query.isEmpty
                    ? l10n.noConversations
                    : l10n.noSearchResults(_query.text.trim()),
                textAlign: TextAlign.center,
                style: context.ariaType.small.copyWith(color: colors.muted),
              ),
            )
          else ...<Widget>[
            Text(
              l10n.conversations,
              style: context.ariaType.tiny.copyWith(
                color: colors.muted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AriaSpacing.xxs),
            for (final session in results)
              _ResultRow(
                session: session,
                onTap: () => Navigator.of(context).pop(session.id),
              ),
          ],
        ],
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

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.session, required this.onTap});

  final AgentSessionSummary session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final title = session.hasTitle ? session.title : l10n.untitled;
    final updated = session.updatedAt;
    final meta = <String>[
      if (session.cwd.trim().isNotEmpty) session.cwd.trim(),
      if (updated != null) formatRelative(context, updated),
    ].join('  ·  ');

    return Material(
      color: Colors.transparent,
      borderRadius: AriaRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AriaRadius.lgAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: ariaMinTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: type.small.copyWith(
                          color: colors.ink,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (meta.isNotEmpty)
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: type.tiny.copyWith(
                            color: colors.muted,
                            letterSpacing: 0,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: colors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
