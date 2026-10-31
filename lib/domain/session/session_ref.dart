/// Identifies one conversation: which agent holds it, and the id that agent
/// assigned it.
///
/// The two halves are never meaningful apart. Two agents may use the same
/// session id, so every lookup — transcript, draft, decisions — is keyed by the
/// pair.
final class SessionRef {
  const SessionRef(this.agentId, this.sessionId);

  final String agentId;
  final String sessionId;

  @override
  bool operator ==(Object other) =>
      other is SessionRef &&
      other.agentId == agentId &&
      other.sessionId == sessionId;

  @override
  int get hashCode => Object.hash(agentId, sessionId);

  @override
  String toString() => 'SessionRef($agentId, $sessionId)';
}
