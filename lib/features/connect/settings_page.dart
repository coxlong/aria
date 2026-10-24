import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../state/settings_controller.dart';

/// Language preference.
final class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settings)),
          body: ListView(
            children: [
              for (final preference in LocalePreference.values)
                ListTile(
                  title: Text(_label(l10n, preference)),
                  selected: preference == settings.preference,
                  onTap: () => settings.setPreference(preference),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _label(AppLocalizations l10n, LocalePreference preference) {
    return switch (preference) {
      LocalePreference.system => l10n.languageSystem,
      LocalePreference.en => l10n.languageEnglish,
      LocalePreference.zh => l10n.languageChinese,
    };
  }
}
