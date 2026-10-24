import 'package:flutter/widgets.dart';

import '../core/persistence/server_store.dart';

/// Language preference. `system` follows the platform locale.
enum LocalePreference { system, en, zh }

/// Persisted app settings.
final class SettingsController extends ChangeNotifier {
  final ServerStore store;

  LocalePreference preference = LocalePreference.system;

  SettingsController(this.store);

  /// Null means "follow the system".
  Locale? get locale => switch (preference) {
    LocalePreference.system => null,
    LocalePreference.en => const Locale('en'),
    LocalePreference.zh => const Locale('zh'),
  };

  Future<void> load() async {
    final raw = await store.loadLocale();
    preference = switch (raw) {
      'en' => LocalePreference.en,
      'zh' => LocalePreference.zh,
      _ => LocalePreference.system,
    };
    notifyListeners();
  }

  Future<void> setPreference(LocalePreference next) async {
    if (preference == next) return;
    preference = next;
    await store.saveLocale(next.name);
    notifyListeners();
  }
}
