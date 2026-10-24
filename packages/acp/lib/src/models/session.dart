/// A session known to the agent (`session/list`) or cached locally.
final class SessionSummary {
  final String sessionId;
  final String cwd;
  final String title;
  final DateTime? updatedAt;

  const SessionSummary({
    required this.sessionId,
    required this.cwd,
    required this.title,
    this.updatedAt,
  });

  factory SessionSummary.fromJson(Map<String, Object?> json) => SessionSummary(
    sessionId: json['sessionId'] as String? ?? '',
    cwd: json['cwd'] as String? ?? '',
    title: json['title'] as String? ?? '',
    updatedAt: _parseTimestamp(json['updatedAt']),
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'sessionId': sessionId,
    'cwd': cwd,
    'title': title,
    'updatedAt': updatedAt?.millisecondsSinceEpoch,
  };

  SessionSummary copyWith({String? title, DateTime? updatedAt}) =>
      SessionSummary(
        sessionId: sessionId,
        cwd: cwd,
        title: title ?? this.title,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Accepts epoch milliseconds (local cache) and ISO-8601 strings (agents).
  static DateTime? _parseTimestamp(Object? value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
