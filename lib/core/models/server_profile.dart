/// A saved agent connection.
final class ServerProfile {
  final String id;
  final String name;
  final String url;

  /// Kept in memory only; persisted in secure storage, never in prefs.
  final String token;
  final String cwd;

  const ServerProfile({
    required this.id,
    required this.name,
    required this.url,
    required this.token,
    required this.cwd,
  });

  String get displayName => name.isEmpty ? url : name;

  /// Metadata only. The token is written separately to secure storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'url': url,
    'cwd': cwd,
  };

  factory ServerProfile.fromJson(Map<String, dynamic> json) => ServerProfile(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    url: json['url'] as String? ?? '',
    token: '',
    cwd: json['cwd'] as String? ?? '',
  );

  ServerProfile copyWith({
    String? name,
    String? url,
    String? token,
    String? cwd,
  }) => ServerProfile(
    id: id,
    name: name ?? this.name,
    url: url ?? this.url,
    token: token ?? this.token,
    cwd: cwd ?? this.cwd,
  );
}
