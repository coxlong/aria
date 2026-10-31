import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_profile.freezed.dart';
part 'server_profile.g.dart';

/// A saved executor endpoint.
///
/// The token is deliberately absent: it lives in secure storage and is only
/// attached to a connection after [ProfileRepository] reads it back.
@freezed
abstract class ServerProfile with _$ServerProfile {
  const factory ServerProfile({
    required String id,
    required String name,
    required String url,
    @Default('') String cwd,

    /// One line saying what this agent handles, shown in the agent list.
    @Default('') String description,
  }) = _ServerProfile;

  factory ServerProfile.fromJson(Map<String, Object?> json) =>
      _$ServerProfileFromJson(json);
}

/// A profile together with its resolved credential, in memory only.
@freezed
abstract class ConnectedProfile with _$ConnectedProfile {
  const factory ConnectedProfile({
    required ServerProfile profile,
    required String token,
  }) = _ConnectedProfile;
}

extension ServerProfileDisplay on ServerProfile {
  String get displayName => name.trim().isEmpty ? url : name;

  String get effectiveCwd => cwd.trim().isEmpty ? '/' : cwd.trim();
}
