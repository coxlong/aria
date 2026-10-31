import '../../core/error/app_error.dart';
import '../decision/decision.dart';
import '../session/agent_session.dart';
import '../session/session_ref.dart';
import 'chat_turn.dart';

/// Everything known about one conversation, independent of any screen.
///
/// The manager owns this state and keeps it current while events arrive, even
/// when no conversation page is mounted. Pages render it; they never own it.
final class ChatSession {
  ChatSession({
    required this.ref,
    this.cwd = '',
    List<ChatTurn> turns = const <ChatTurn>[],
    this.running = false,
    this.stopping = false,
    this.loaded = false,
    this.loading = false,
    this.surfaces = SessionSurfaces.none,
    List<Decision> decisions = const <Decision>[],
    this.error,
  }) : turns = List<ChatTurn>.unmodifiable(turns),
       decisions = List<Decision>.unmodifiable(decisions);

  static const Object _keep = Object();

  final SessionRef ref;

  /// Working directory the agent opened this session with.
  final String cwd;

  /// Finished turns in order, plus the live one when it is running.
  final List<ChatTurn> turns;

  final bool running;
  final bool stopping;

  /// History has been replayed and the session can be shown.
  final bool loaded;

  /// A `session/load` is in flight.
  final bool loading;

  /// Model, mode and effort as the agent advertised them for this session.
  final SessionSurfaces surfaces;

  final List<Decision> decisions;
  final AppError? error;

  String get agentId => ref.agentId;
  String get sessionId => ref.sessionId;

  ChatTurn? get lastTurn => turns.isEmpty ? null : turns.last;

  bool get hasTurns => turns.isNotEmpty;

  /// The first decision still waiting for the person.
  Decision? get pendingDecision {
    for (final decision in decisions) {
      if (decision.isPending) return decision;
    }
    return null;
  }

  /// How many decisions are waiting behind the one being shown.
  int get queuedDecisions {
    var pending = 0;
    for (final decision in decisions) {
      if (decision.isPending) pending++;
    }
    return pending > 1 ? pending - 1 : 0;
  }

  bool get waiting => pendingDecision != null;

  ChatSession copyWith({
    String? cwd,
    List<ChatTurn>? turns,
    bool? running,
    bool? stopping,
    bool? loaded,
    bool? loading,
    SessionSurfaces? surfaces,
    List<Decision>? decisions,
    Object? error = _keep,
  }) => ChatSession(
    ref: ref,
    cwd: cwd ?? this.cwd,
    turns: turns ?? this.turns,
    running: running ?? this.running,
    stopping: stopping ?? this.stopping,
    loaded: loaded ?? this.loaded,
    loading: loading ?? this.loading,
    surfaces: surfaces ?? this.surfaces,
    decisions: decisions ?? this.decisions,
    error: identical(error, _keep) ? this.error : error as AppError?,
  );
}
