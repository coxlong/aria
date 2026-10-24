/// Basic protocol value objects.
library;

/// Client identity sent in `initialize`.
final class ClientInfo {
  final String name;
  final String title;
  final String version;

  const ClientInfo({
    required this.name,
    required this.title,
    required this.version,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'title': title,
    'version': version,
  };
}

/// One authentication method advertised by the agent.
final class AuthMethod {
  final String id;
  final String name;

  const AuthMethod({required this.id, required this.name});

  factory AuthMethod.fromJson(Map<String, Object?> json) => AuthMethod(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? json['id'] as String? ?? '',
  );
}

/// Parsed `initialize` result.
final class InitializeResult {
  final int protocolVersion;
  final bool supportsLoadSession;
  final bool supportsSessionList;

  /// Whether the agent accepts `session/delete`.
  final bool supportsSessionDelete;

  final List<AuthMethod> authMethods;

  const InitializeResult({
    required this.protocolVersion,
    required this.supportsLoadSession,
    required this.supportsSessionList,
    required this.supportsSessionDelete,
    required this.authMethods,
  });

  factory InitializeResult.fromJson(Map<String, Object?> json) {
    final caps =
        json['agentCapabilities'] as Map<String, Object?>? ??
        const <String, Object?>{};
    final sessionCaps =
        caps['sessionCapabilities'] as Map<String, Object?>? ??
        const <String, Object?>{};
    return InitializeResult(
      protocolVersion: json['protocolVersion'] as int? ?? 1,
      supportsLoadSession: caps['loadSession'] == true,
      supportsSessionList: sessionCaps['list'] != null,
      supportsSessionDelete: sessionCaps['delete'] != null,
      authMethods: (json['authMethods'] as List<Object?>? ?? const [])
          .whereType<Map<String, Object?>>()
          .map(AuthMethod.fromJson)
          .toList(growable: false),
    );
  }
}

/// Result of a completed prompt turn.
final class PromptResult {
  /// One of `end_turn`, `max_tokens`, `cancelled`, `refusal`, `unknown`.
  final String stopReason;

  const PromptResult(this.stopReason);

  bool get isCancelled => stopReason == 'cancelled';

  factory PromptResult.fromJson(Map<String, Object?> json) =>
      PromptResult(json['stopReason'] as String? ?? 'unknown');
}
