import '../../core/error/app_error.dart';
import '../profile/server_profile.dart';
import 'agent_session.dart';

/// Where one agent connection stands.
///
/// [reconnecting] is deliberately its own state: the transport is retrying and
/// the sessions are still alive, so a running turn must not read as finished.
enum AgentStatus { idle, connecting, connected, reconnecting, failed }

/// Connection-level state for one agent.
///
/// A connection is not a conversation: this holds the transport status, what
/// the agent can do, and the sessions it knows about. Conversation contents
/// live in `ChatSession`, keyed by `SessionRef`, so several agents and several
/// sessions can be live at once.
final class AgentConnection {
  const AgentConnection({
    required this.profile,
    this.status = AgentStatus.idle,
    this.error,
    this.capabilities = const AgentCapabilities(),
    this.sessions = const <AgentSessionSummary>[],
  });

  static const Object _keep = Object();

  final ServerProfile profile;
  final AgentStatus status;
  final AppError? error;
  final AgentCapabilities capabilities;

  /// The agent's own session list, newest first.
  final List<AgentSessionSummary> sessions;

  bool get isConnected =>
      status == AgentStatus.connected || status == AgentStatus.reconnecting;

  bool get isBusy =>
      status == AgentStatus.connecting || status == AgentStatus.reconnecting;

  /// Whether the session list can be fetched again right now.
  bool get canRefresh =>
      status == AgentStatus.connected && capabilities.canListSessions;

  AgentConnection copyWith({
    AgentStatus? status,
    Object? error = _keep,
    AgentCapabilities? capabilities,
    List<AgentSessionSummary>? sessions,
  }) => AgentConnection(
    profile: profile,
    status: status ?? this.status,
    error: identical(error, _keep) ? this.error : error as AppError?,
    capabilities: capabilities ?? this.capabilities,
    sessions: sessions ?? this.sessions,
  );
}
