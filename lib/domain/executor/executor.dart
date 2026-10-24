import '../../core/error/app_error.dart';
import '../chat/work_step.dart';
import '../decision/decision.dart';
import '../session/agent_session.dart';

/// Runs work on the person's behalf.
///
/// ACP is one implementation; the interface exists so the product can gain
/// other executors without the interface knowing which one is running. The UI
/// only ever sees these types — no protocol shape leaks through.
abstract interface class Executor {
  /// Everything that happens inside a session, in wire order.
  Stream<ExecutorEvent> get events;

  /// Transport health. Kept apart from turn state on purpose: reconnecting must
  /// never read as a finished turn.
  Stream<ExecutorConnection> get connection;

  /// The configuration surface of the open session.
  SessionSurfaces get surfaces;

  Future<AgentCapabilities> connect();

  Future<List<AgentSessionSummary>> listSessions({String? cwd});
  Future<AgentSession> newSession({required String cwd});
  Future<AgentSession> openSession({required String id, required String cwd});
  Future<void> deleteSession(String id);

  /// Starts forwarding this session's updates.
  ///
  /// A resumed session buffers its replay until the caller attaches, so the
  /// chat surface decides when history begins arriving — never before it can
  /// render it.
  void attach(String sessionId);

  Future<void> prompt({required String sessionId, required String text});
  Future<void> cancel(String sessionId);

  /// Answers a decision exactly once.
  Future<void> answer(DecisionAnswer answer);

  Future<void> setModel(String id);
  Future<void> setMode(String id);
  Future<void> setConfigOption(String configId, String value);

  Future<void> dispose();
}

/// The person's answer to a [Decision].
final class DecisionAnswer {
  const DecisionAnswer({required this.decisionId, this.optionId});

  final String decisionId;

  /// Null means "cancelled", which the protocol reports separately.
  final String? optionId;

  bool get isCancelled => optionId == null;
}

/// Transport health.
enum ExecutorConnection { connecting, connected, reconnecting, closed, failed }

/// Anything an [Executor] reports about a session.
sealed class ExecutorEvent {
  const ExecutorEvent(this.sessionId);

  final String sessionId;
}

/// The agent echoed a user message. Only meaningful during history replay; a
/// live turn is opened by the controller from the text it sent.
final class UserPrompt extends ExecutorEvent {
  const UserPrompt(super.sessionId, this.text);

  final String text;
}

/// Streamed assistant text.
final class AgentText extends ExecutorEvent {
  const AgentText(super.sessionId, this.text);

  final String text;
}

/// Streamed reasoning. Never shown in the conversation; it lives in the work
/// summary.
final class AgentThought extends ExecutorEvent {
  const AgentThought(super.sessionId, this.text);

  final String text;
}

/// A step was added or changed. Matching is by [WorkStep.id].
final class StepChanged extends ExecutorEvent {
  const StepChanged(super.sessionId, this.step);

  final WorkStep step;
}

/// The agent needs a decision before it can continue.
final class DecisionRaised extends ExecutorEvent {
  const DecisionRaised(super.sessionId, this.decision);

  final Decision decision;
}

/// The turn ended. Whatever arrived is durable.
final class ExecutionFinished extends ExecutorEvent {
  const ExecutionFinished(super.sessionId, {required this.stopReason});

  /// `end_turn`, `max_tokens`, `refusal`, `cancelled`, or `error`.
  final String stopReason;
}

/// The turn failed.
final class ExecutionFailed extends ExecutorEvent {
  const ExecutionFailed(super.sessionId, this.error);

  final AppError error;
}

/// Models, modes, or effort levels changed.
final class SurfacesChanged extends ExecutorEvent {
  const SurfacesChanged(super.sessionId);
}
