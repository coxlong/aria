import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/profile/server_profile.dart';

part 'app_settings.freezed.dart';

/// Everything the settings surface owns.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(<ServerProfile>[]) List<ServerProfile> profiles,
    String? activeProfileId,

    /// `system`, `en`, or `zh`.
    @Default('system') String locale,
  }) = _AppSettings;

  const AppSettings._();

  ServerProfile? get activeProfile {
    final id = activeProfileId;
    if (id == null) return null;
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  bool get hasProfiles => profiles.isNotEmpty;
}
