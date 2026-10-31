import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../core/widgets/aria_sheet.dart';
import '../../../core/widgets/aria_toast.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/application/agent_manager.dart';
import '../application/settings_controller.dart';

/// Opens settings as one sheet that changes pages in place.
Future<void> showSettings(
  BuildContext context, {
  bool openAgents = false,
  bool newAgent = false,
}) {
  return showAriaSheet<void>(
    context: context,
    builder: (context) => SettingsSheet(
      initialPage: newAgent
          ? 2
          : openAgents
          ? 1
          : 0,
    ),
  );
}

enum _SettingsPage { root, agents, agentEdit }

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key, this.initialPage = 0});

  final int initialPage;

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  late _SettingsPage _page = switch (widget.initialPage) {
    1 => _SettingsPage.agents,
    2 => _SettingsPage.agentEdit,
    _ => _SettingsPage.root,
  };
  String? _editingId;

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _SettingsPage.root => _RootPage(
        onAgents: () => setState(() => _page = _SettingsPage.agents),
      ),
      _SettingsPage.agents => _AgentsPage(
        onBack: () => setState(() => _page = _SettingsPage.root),
        onEdit: (id) => setState(() {
          _editingId = id;
          _page = _SettingsPage.agentEdit;
        }),
        onClose: () => Navigator.of(context).pop(),
      ),
      _SettingsPage.agentEdit => _AgentEditPage(
        key: ValueKey<String>(_editingId ?? 'new'),
        profileId: _editingId ?? 'new',
        onBack: () => setState(() => _page = _SettingsPage.agents),
        onSaved: () {
          // Opening the form straight from the wake screen returns there once
          // the new agent exists; there is nothing else to manage yet.
          if (widget.initialPage == 2 && _editingId == null) {
            Navigator.of(context).pop();
          } else {
            setState(() => _page = _SettingsPage.agents);
          }
        },
      ),
    };
  }
}

class _RootPage extends ConsumerWidget {
  const _RootPage({required this.onAgents});

  final VoidCallback onAgents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final settings = ref.watch(settingsProvider);
    final manager = ref.watch(agentManagerProvider);
    final connectedAgent = manager.activeAgent;
    final active = settings.activeProfile;
    final connected = connectedAgent?.isConnected ?? false;
    final agentName = connected
        ? '${l10n.connected} · ${connectedAgent!.profile.displayName}'
        : (active?.displayName ?? l10n.notConnected);

    return AriaSheet(
      title: l10n.settings,
      onClose: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PrefRow(
            label: l10n.theme,
            child: AriaSegmented<String>(
              values: const <String>['dark', 'light', 'system'],
              labels: <String>[
                l10n.themeDark,
                l10n.themeLight,
                l10n.themeSystem,
              ],
              selected: settings.themeMode,
              onChanged: (value) => unawaited(
                ref.read(settingsProvider.notifier).setThemeMode(value),
              ),
            ),
          ),
          const SizedBox(height: AriaSpacing.xxs),
          _PrefRow(
            label: l10n.language,
            child: AriaSegmented<String>(
              values: const <String>['system', 'zh', 'en'],
              labels: <String>[
                l10n.languageSystem,
                l10n.languageChinese,
                l10n.languageEnglish,
              ],
              selected: settings.locale,
              onChanged: (value) => unawaited(
                ref.read(settingsProvider.notifier).setLocale(value),
              ),
            ),
          ),
          const SizedBox(height: AriaSpacing.xxs),
          Material(
            color: Colors.transparent,
            borderRadius: AriaRadius.lgAll,
            child: InkWell(
              onTap: onAgents,
              borderRadius: AriaRadius.lgAll,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 62,
                        child: Text(
                          l10n.agent,
                          style: context.ariaType.caption.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          agentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.ariaType.caption.copyWith(
                            color: colors.ink2,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: colors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (connectedAgent != null && connectedAgent.isConnected) ...<Widget>[
            const SizedBox(height: AriaSpacing.lg),
            AriaLinkButton(
              label: l10n.disconnect,
              onTap: () {
                Navigator.of(context).pop();
                showAriaToast(l10n.disconnectedKept);
                unawaited(
                  ref
                      .read(agentManagerProvider.notifier)
                      .disconnect(connectedAgent.profile.id),
                );
              },
            ),
          ],
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

class _PrefRow extends StatelessWidget {
  const _PrefRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: context.ariaType.caption.copyWith(color: colors.muted),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AgentsPage extends ConsumerWidget {
  const _AgentsPage({
    required this.onBack,
    required this.onEdit,
    required this.onClose,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onEdit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final settings = ref.watch(settingsProvider);

    return AriaSheet(
      title: l10n.agents,
      onBack: onBack,
      onClose: onClose,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final profile in settings.profiles)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _AgentRow(
                profile: profile,
                isDefault: profile.id == settings.activeProfileId,
                onTap: () => onEdit(profile.id),
              ),
            ),
          if (settings.profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AriaSpacing.md),
              child: Text(
                l10n.noAgents,
                style: context.ariaType.small.copyWith(color: colors.muted),
              ),
            ),
          const SizedBox(height: AriaSpacing.xxs),
          Material(
            color: Colors.transparent,
            borderRadius: AriaRadius.smAll,
            child: InkWell(
              onTap: () => onEdit('new'),
              borderRadius: AriaRadius.smAll,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: ariaMinTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.add_rounded, size: 16, color: colors.muted),
                      const SizedBox(width: AriaSpacing.xs),
                      Text(
                        l10n.addAgent,
                        style: context.ariaType.small.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      foot: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              child: Text(l10n.backToSettings),
            ),
          ),
          const SizedBox(width: AriaSpacing.xs),
          Expanded(
            child: FilledButton(onPressed: onClose, child: Text(l10n.done)),
          ),
        ],
      ),
    );
  }
}

class _AgentRow extends StatelessWidget {
  const _AgentRow({
    required this.profile,
    required this.isDefault,
    required this.onTap,
  });

  final ServerProfile profile;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    final description = profile.description.trim().isNotEmpty
        ? profile.description.trim()
        : profile.url;

    return Material(
      color: Colors.transparent,
      borderRadius: AriaRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AriaRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            profile.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: type.chatTitle.copyWith(color: colors.ink),
                          ),
                        ),
                        if (isDefault) ...<Widget>[
                          const SizedBox(width: AriaSpacing.xs),
                          Container(
                            padding: const EdgeInsets.fromLTRB(9, 3, 9, 3),
                            decoration: BoxDecoration(
                              color: colors.goldSoft,
                              borderRadius: AriaRadius.pillAll,
                            ),
                            child: Text(
                              l10n.agentDefault,
                              style: type.tiny.copyWith(
                                color: colors.gold,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: type.caption.copyWith(
                        fontSize: 12.5,
                        color: colors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AriaSpacing.xs),
              Icon(Icons.chevron_right_rounded, size: 15, color: colors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgentEditPage extends ConsumerStatefulWidget {
  const _AgentEditPage({
    super.key,
    required this.profileId,
    required this.onBack,
    required this.onSaved,
  });

  final String profileId;
  final VoidCallback onBack;
  final VoidCallback onSaved;

  @override
  ConsumerState<_AgentEditPage> createState() => _AgentEditPageState();
}

class _AgentEditPageState extends ConsumerState<_AgentEditPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _url = TextEditingController();
  final TextEditingController _cwd = TextEditingController();
  final TextEditingController _token = TextEditingController();

  ServerProfile? _existing;
  bool _loaded = false;
  bool _saving = false;
  String? _nameError;
  String? _urlError;
  String? _cwdError;
  String? _actionError;

  bool get _isNew => widget.profileId == 'new';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final settings = ref.read(settingsProvider);
    for (final profile in settings.profiles) {
      if (profile.id == widget.profileId) _existing = profile;
    }
    final existing = _existing;
    if (existing != null) {
      _name.text = existing.name;
      _desc.text = existing.description;
      _url.text = existing.url;
      _cwd.text = existing.cwd;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _url.dispose();
    _cwd.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final settings = ref.watch(settingsProvider);
    final manager = ref.watch(agentManagerProvider);
    final existing = _existing;
    final isDefault =
        existing != null && existing.id == settings.activeProfileId;
    final connected =
        existing != null && (manager.agents[existing.id]?.isConnected ?? false);
    final anyConnected = manager.agents.values.any(
      (agent) => agent.isConnected,
    );
    final locked = connected;

    return AriaSheet(
      title: _isNew ? l10n.addAgent : (existing?.displayName ?? l10n.agent),
      onBack: widget.onBack,
      onClose: () => Navigator.of(context).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!_isNew && existing != null) ...<Widget>[
            _AgentStateLine(profile: existing, connected: connected),
            const SizedBox(height: AriaSpacing.md),
          ],
          _Field(
            label: l10n.agentName,
            controller: _name,
            hint: _isNew ? l10n.agentNameHint : null,
            error: _nameError,
            maxLength: 8,
            autofocus: _isNew,
            onChanged: () => setState(() => _nameError = null),
          ),
          const SizedBox(height: AriaSpacing.md),
          _Field(
            label: l10n.agentDesc,
            controller: _desc,
            hint: l10n.agentDescHint,
            maxLength: 60,
          ),
          const SizedBox(height: AriaSpacing.md),
          _Field(
            label: l10n.executorUrl,
            controller: _url,
            hint: 'ws://127.0.0.1:3000',
            error: _urlError,
            keyboardType: TextInputType.url,
            readOnly: locked,
            onChanged: () => setState(() => _urlError = null),
          ),
          const SizedBox(height: AriaSpacing.md),
          _Field(
            label: l10n.executorToken,
            controller: _token,
            hint: _isNew ? l10n.tokenOptionalHint : l10n.tokenUnchanged,
            obscure: true,
            readOnly: locked,
          ),
          const SizedBox(height: AriaSpacing.md),
          _Field(
            label: l10n.executorCwd,
            controller: _cwd,
            hint: l10n.executorCwdHint,
            error: _cwdError,
            readOnly: locked,
            onChanged: () => setState(() => _cwdError = null),
          ),
          if (locked) ...<Widget>[
            const SizedBox(height: AriaSpacing.xs),
            AriaNote(l10n.agentLocked),
          ],
          if (!_isNew) ...<Widget>[
            const SizedBox(height: AriaSpacing.md),
            Wrap(
              spacing: AriaSpacing.md,
              runSpacing: AriaSpacing.xxs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                if (connected)
                  AriaLinkButton(
                    label: l10n.disconnect,
                    danger: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      showAriaToast(l10n.disconnectedKept);
                      unawaited(
                        ref
                            .read(agentManagerProvider.notifier)
                            .disconnect(existing.id),
                      );
                    },
                  )
                else if (!anyConnected)
                  AriaLinkButton(
                    label: l10n.connectThisAgent,
                    onTap: () {
                      unawaited(
                        ref
                            .read(settingsProvider.notifier)
                            .setConnectProfile(existing!.id),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                if (!isDefault)
                  AriaLinkButton(
                    label: l10n.makeDefault,
                    onTap: () {
                      unawaited(
                        ref
                            .read(settingsProvider.notifier)
                            .setActiveProfile(existing!.id),
                      );
                      showAriaToast(l10n.defaultSet(existing.displayName));
                      setState(() => _actionError = null);
                    },
                  ),
                if (!isDefault && !connected)
                  AriaLinkButton(
                    label: l10n.delete,
                    danger: true,
                    onTap: () => _delete(existing!),
                  ),
              ],
            ),
            if (isDefault)
              Padding(
                padding: const EdgeInsets.only(top: AriaSpacing.xs),
                child: AriaNote(l10n.defaultCannotDelete),
              )
            else if (connected)
              Padding(
                padding: const EdgeInsets.only(top: AriaSpacing.xs),
                child: AriaNote(l10n.disconnectToDelete),
              ),
            if (_actionError != null)
              Padding(
                padding: const EdgeInsets.only(top: AriaSpacing.xs),
                child: Text(
                  _actionError!,
                  style: context.ariaType.caption.copyWith(
                    color: colors.danger,
                  ),
                ),
              ),
          ],
        ],
      ),
      foot: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onBack,
              child: Text(l10n.cancel),
            ),
          ),
          const SizedBox(width: AriaSpacing.xs),
          Expanded(
            child: FilledButton(
              onPressed: _saving ? null : () => unawaited(_save()),
              child: Text(_isNew ? l10n.add : l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final url = _url.text.trim();
    final cwd = _cwd.text.trim();
    var valid = true;
    final settings = ref.read(settingsProvider);
    final duplicate = settings.profiles.any(
      (profile) =>
          profile.id != _existing?.id &&
          profile.name.trim().toLowerCase() == name.toLowerCase(),
    );
    setState(() {
      _nameError = name.isEmpty
          ? l10n.requiredField
          : duplicate
          ? l10n.agentNameTaken
          : null;
      _urlError = url.isEmpty
          ? l10n.requiredField
          : (!url.startsWith('ws://') && !url.startsWith('wss://'))
          ? l10n.executorUrlInvalid
          : null;
      _cwdError = cwd.isEmpty ? l10n.requiredField : null;
    });
    if (_nameError != null || _urlError != null || _cwdError != null) {
      valid = false;
    }
    if (!valid) return;

    setState(() => _saving = true);
    final controller = ref.read(settingsProvider.notifier);
    final token = _token.text;
    final existing = _existing;

    try {
      if (existing == null) {
        final created = await controller.addProfile(
          name: name,
          description: _desc.text,
          url: url,
          cwd: cwd,
          token: token,
        );
        await controller.setConnectProfile(created.id);
      } else {
        await controller.updateProfile(
          existing.copyWith(
            name: name,
            description: _desc.text.trim(),
            url: url,
            cwd: cwd,
          ),
          token: token.isEmpty ? null : token,
        );
      }
      if (!mounted) return;
      showAriaToast(_isNew ? l10n.agentAdded(name) : l10n.agentSaved);
      widget.onSaved();
    } on Object {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _actionError = l10n.errorStorage;
      });
    }
  }

  Future<void> _delete(ServerProfile profile) async {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.sheet,
        title: Text(l10n.delete),
        content: Text(l10n.deleteAgentConfirm(profile.displayName)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colors.dangerSoft,
              foregroundColor: colors.danger,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(settingsProvider.notifier).deleteProfile(profile.id);
    if (!mounted) return;
    showAriaToast(l10n.agentDeleted(profile.displayName));
    setState(() => _existing = null);
    widget.onSaved();
  }
}

/// One agent's connection state and where it points, before its fields.
class _AgentStateLine extends StatelessWidget {
  const _AgentStateLine({required this.profile, required this.connected});

  final ServerProfile profile;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;
    return Row(
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: connected ? colors.goldFill : colors.panel3,
            boxShadow: connected
                ? <BoxShadow>[BoxShadow(color: colors.goldGlow, blurRadius: 10)]
                : null,
          ),
        ),
        const SizedBox(width: AriaSpacing.xs),
        Text(
          connected ? l10n.connected : l10n.notConnected,
          style: type.caption.copyWith(
            color: colors.ink2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AriaSpacing.sm),
        Expanded(
          child: Text(
            profile.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: type.code.copyWith(color: colors.muted, fontSize: 10.5),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.error,
    this.obscure = false,
    this.readOnly = false,
    this.maxLength,
    this.keyboardType,
    this.autofocus = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? error;
  final bool obscure;
  final bool readOnly;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool autofocus;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    final type = context.ariaType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label,
          style: type.caption.copyWith(
            color: colors.ink2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            readOnly: readOnly,
            autofocus: autofocus,
            maxLength: maxLength,
            keyboardType: keyboardType,
            autocorrect: false,
            onChanged: onChanged == null ? null : (_) => onChanged!(),
            style: type.body.copyWith(
              color: readOnly ? colors.muted : colors.ink,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? colors.panelDeep : colors.panel,
              counterText: '',
              hintText: hint,
              hintStyle: type.ui.copyWith(color: colors.muted),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: AriaRadius.mdAll,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AriaRadius.mdAll,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AriaRadius.mdAll,
                borderSide: BorderSide(color: colors.focus, width: 2),
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error!,
              style: type.caption.copyWith(color: colors.danger),
            ),
          ),
      ],
    );
  }
}
