import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/profile/server_profile.dart';

part 'app_settings.freezed.dart';

/// Everything the settings surface owns.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(<ServerProfile>[]) List<ServerProfile> profiles,
    String? activeProfileId,

    /// The agent the wake screen offers. Independent of the default: choosing
    /// who answers next does not change which agent new work defaults to.
    String? connectProfileId,

    /// `system`, `en`, or `zh`.
    @Default('system') String locale,

    /// `dark`, `light`, or `system`.
    @Default('dark') String themeMode,
  }) = _AppSettings;

  const AppSettings._();

  ServerProfile? get activeProfile => _profile(activeProfileId);

  ServerProfile? get connectProfile => _profile(connectProfileId);

  /// The profile the wake screen should show: the last one chosen, else the
  /// default, else the first saved.
  ServerProfile? get profileToConnect =>
      connectProfile ??
      activeProfile ??
      (profiles.isEmpty ? null : profiles.first);

  ServerProfile? _profile(String? id) {
    if (id == null) return null;
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  bool get hasProfiles => profiles.isNotEmpty;
}
