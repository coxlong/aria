import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/models/server_profile.dart';
import '../../l10n/app_localizations.dart';

/// Creates or edits a saved server. A null [profile] means "new".
final class ServerEditPage extends StatefulWidget {
  const ServerEditPage({super.key, this.profile});

  final ServerProfile? profile;

  @override
  State<ServerEditPage> createState() => _ServerEditPageState();
}

class _ServerEditPageState extends State<ServerEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _url;
  late final TextEditingController _token;
  late final TextEditingController _cwd;
  bool _saving = false;

  bool get _isNew => widget.profile == null;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _name = TextEditingController(text: profile?.name ?? '');
    _url = TextEditingController(text: profile?.url ?? '');
    _token = TextEditingController(text: profile?.token ?? '');
    _cwd = TextEditingController(text: profile?.cwd ?? '/');
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _token.dispose();
    _cwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? l10n.addServer : l10n.editServer)),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              key: const Key('serverName'),
              controller: _name,
              decoration: InputDecoration(labelText: l10n.serverName),
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              key: const Key('serverUrl'),
              controller: _url,
              decoration: InputDecoration(labelText: l10n.serverUrl),
              keyboardType: TextInputType.url,
              autocorrect: false,
              validator: _validateUrl,
            ),
            TextFormField(
              key: const Key('serverToken'),
              controller: _token,
              decoration: InputDecoration(labelText: l10n.serverToken),
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
            ),
            TextFormField(
              key: const Key('serverCwd'),
              controller: _cwd,
              decoration: InputDecoration(
                labelText: l10n.serverCwd,
                hintText: l10n.serverCwdHint,
              ),
              autocorrect: false,
            ),
            TextButton(
              key: const Key('saveServer'),
              onPressed: _saving ? null : _save,
              child: Text(l10n.save),
            ),
            if (!_isNew)
              TextButton(
                onPressed: _saving ? null : _delete,
                child: Text(l10n.deleteServer),
              ),
          ],
        ),
      ),
    );
  }

  String? _validateUrl(String? value) {
    final l10n = AppLocalizations.of(context);
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.requiredField;
    final uri = Uri.tryParse(text);
    final isWebSocket =
        uri != null &&
        (uri.scheme == 'ws' || uri.scheme == 'wss') &&
        uri.host.isNotEmpty;
    return isWebSocket ? null : l10n.serverUrlInvalid;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final scope = AppScope.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    final saved = await scope.servers.save(
      ServerProfile(
        id: widget.profile?.id ?? '',
        name: _name.text.trim(),
        url: _url.text.trim(),
        token: _token.text.trim(),
        cwd: _cwd.text.trim(),
      ),
    );
    if (!mounted) return;
    navigator.pop(saved);
  }

  Future<void> _delete() async {
    final profile = widget.profile;
    if (profile == null) return;
    final l10n = AppLocalizations.of(context);
    final scope = AppScope.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteServer),
        content: Text(l10n.deleteServerConfirm(profile.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    await scope.servers.delete(profile.id);
    if (!mounted) return;
    navigator.pop();
  }
}
