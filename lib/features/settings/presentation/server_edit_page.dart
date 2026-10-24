import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/aria_colors.dart';
import '../../../core/theme/aria_tokens.dart';
import '../../../core/theme/aria_type.dart';
import '../../../domain/profile/server_profile.dart';
import '../../../l10n/app_localizations.dart';
import '../application/settings_controller.dart';

/// Adds or edits one executor endpoint.
class ServerEditPage extends ConsumerStatefulWidget {
  const ServerEditPage({super.key, required this.profileId});

  /// A profile id, or `new`.
  final String profileId;

  @override
  ConsumerState<ServerEditPage> createState() => _ServerEditPageState();
}

class _ServerEditPageState extends ConsumerState<ServerEditPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _url;
  late final TextEditingController _cwd;
  final TextEditingController _token = TextEditingController();

  ServerProfile? _existing;
  bool _loaded = false;

  bool get _isNew => widget.profileId == 'new';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _url = TextEditingController();
    _cwd = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    if (_isNew) return;

    final settings = ref.read(settingsProvider);
    for (final profile in settings.profiles) {
      if (profile.id == widget.profileId) _existing = profile;
    }
    final existing = _existing;
    if (existing != null) {
      _name.text = existing.name;
      _url.text = existing.url;
      _cwd.text = existing.cwd;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _cwd.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ariaColors;
    final type = context.ariaType;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.cancel,
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(_isNew ? l10n.addExecutor : l10n.editExecutor),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AriaSpacing.readingColumn,
          ),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(AriaSpacing.lg),
              children: <Widget>[
                _Field(controller: _name, label: l10n.executorName, hint: null),
                const SizedBox(height: AriaSpacing.md),
                _Field(
                  controller: _url,
                  label: l10n.executorUrl,
                  hint: 'ws://127.0.0.1:3000',
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return l10n.requiredField;
                    if (!trimmed.startsWith('ws://') &&
                        !trimmed.startsWith('wss://')) {
                      return l10n.executorUrlInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AriaSpacing.md),
                _Field(
                  controller: _cwd,
                  label: l10n.executorCwd,
                  hint: l10n.executorCwdHint,
                ),
                const SizedBox(height: AriaSpacing.md),
                _Field(
                  controller: _token,
                  label: l10n.executorToken,
                  hint: _isNew ? null : l10n.tokenUnchanged,
                  obscure: true,
                ),
                const SizedBox(height: AriaSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: () => unawaited(_save()),
                    child: Text(l10n.save),
                  ),
                ),
                const SizedBox(height: AriaSpacing.lg),
                Text(
                  _isNew ? l10n.noExecutorsBody : l10n.executorCwdHint,
                  style: type.caption.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_form.currentState?.validate() != true) return;
    final controller = ref.read(settingsProvider.notifier);
    final token = _token.text;

    final existing = _existing;
    if (existing == null) {
      await controller.addProfile(
        name: _name.text,
        url: _url.text,
        cwd: _cwd.text,
        token: token,
      );
    } else {
      await controller.updateProfile(
        existing.copyWith(
          name: _name.text.trim(),
          url: _url.text.trim(),
          cwd: _cwd.text.trim(),
        ),
        token: token.isEmpty ? null : token,
      );
    }

    if (mounted) context.pop();
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final colors = context.ariaColors;
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      autocorrect: false,
      style: context.ariaType.body.copyWith(color: colors.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: context.ariaType.ui.copyWith(color: colors.textMuted),
        hintStyle: context.ariaType.ui.copyWith(color: colors.textMuted),
      ),
    );
  }
}
