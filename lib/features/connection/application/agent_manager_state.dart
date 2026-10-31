import '../../../domain/chat/chat_session.dart';
import '../../../domain/session/agent_connection.dart';
import '../../../domain/session/session_ref.dart';

/// Everything the app knows about every agent and every conversation.
///
/// Two levels, on purpose:
/// - [agents] is connection state, keyed by profile id.
/// - [sessions] is conversation state, keyed by `(agent, session)`.
///
/// A page may come and go; this map does not. That is what lets a turn keep
/// running while the person is on home, and what lets a second agent connect
/// without disturbing the first.
final class AgentManagerState {
  const AgentManagerState({
    this.agents = const <String, AgentConnection>{},
    this.order = const <String>[],
    this.activeAgentId,
    this.sessions = const <SessionRef, ChatSession>{},
    this.drafts = const <SessionRef, String>{},
    this.openSessions = const <String, String>{},
  });

  static const Object _keep = Object();

  /// Connection state per agent profile id.
  final Map<String, AgentConnection> agents;

  /// Connection order, for the agent list and for choosing a fallback.
  final List<String> order;

  /// The agent the surfaces are currently showing.
  final String? activeAgentId;

  /// Conversation state for every session this app is following.
  final Map<SessionRef, ChatSession> sessions;

  /// Unsent composer text, per conversation.
  final Map<SessionRef, String> drafts;

  /// The conversation open for each agent, so switching agents restores it.
  final Map<String, String> openSessions;

  AgentConnection? get activeAgent =>
      activeAgentId == null ? null : agents[activeAgentId];

  bool get isConnected => activeAgent?.isConnected ?? false;

  bool get isBusy => activeAgent?.isBusy ?? false;

  String? get activeSessionId =>
      activeAgentId == null ? null : openSessions[activeAgentId];

  SessionRef? get activeSessionRef {
    final agentId = activeAgentId;
    final sessionId = activeSessionId;
    if (agentId == null || sessionId == null) return null;
    return SessionRef(agentId, sessionId);
  }

  /// The open conversation of the active agent, or null when none is open.
  ChatSession? get activeSession {
    final ref = activeSessionRef;
    return ref == null ? null : session(ref);
  }

  /// One conversation. A session that has not produced state yet reads as an
  /// empty one, so pages never have to handle a missing object and a fresh one
  /// differently.
  ChatSession session(SessionRef ref) => sessions[ref] ?? ChatSession(ref: ref);

  AgentConnection? agent(String id) => agents[id];

  String draft(SessionRef ref) => drafts[ref] ?? '';

  bool isOpen(SessionRef ref) => openSessions[ref.agentId] == ref.sessionId;

  AgentManagerState copyWith({
    Map<String, AgentConnection>? agents,
    List<String>? order,
    Object? activeAgentId = _keep,
    Map<SessionRef, ChatSession>? sessions,
    Map<SessionRef, String>? drafts,
    Map<String, String>? openSessions,
  }) => AgentManagerState(
    agents: agents ?? this.agents,
    order: order ?? this.order,
    activeAgentId: identical(activeAgentId, _keep)
        ? this.activeAgentId
        : activeAgentId as String?,
    sessions: sessions ?? this.sessions,
    drafts: drafts ?? this.drafts,
    openSessions: openSessions ?? this.openSessions,
  );
}
