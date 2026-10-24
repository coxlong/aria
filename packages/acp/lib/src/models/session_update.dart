import 'tool_call.dart';

/// A `session/update` notification, parsed into a typed value.
///
/// Unknown variants are preserved as [UnknownSessionUpdate] so a newer agent
/// never breaks dispatch.
sealed class SessionUpdate {
  final String sessionId;

  const SessionUpdate(this.sessionId);
}

/// A user message chunk (mostly seen while replaying a loaded session).
final class UserMessageChunk extends SessionUpdate {
  final String text;

  const UserMessageChunk(super.sessionId, this.text);
}

/// A streamed assistant text chunk.
final class AgentMessageChunk extends SessionUpdate {
  final String text;

  const AgentMessageChunk(super.sessionId, this.text);
}

/// A streamed reasoning chunk.
final class AgentThoughtChunk extends SessionUpdate {
  final String text;

  const AgentThoughtChunk(super.sessionId, this.text);
}

/// A new tool call.
final class ToolCallStarted extends SessionUpdate {
  final ToolCallInfo toolCall;

  const ToolCallStarted(super.sessionId, this.toolCall);
}

/// A patch to an existing tool call. Fields are null when the frame did not
/// carry them ("leave unchanged").
final class ToolCallPatched extends SessionUpdate {
  final String toolCallId;
  final String? title;
  final String? status;
  final Object? rawInput;
  final Object? rawOutput;
  final List<Map<String, Object?>>? content;
  final Map<String, Object?>? meta;

  const ToolCallPatched(
    super.sessionId, {
    required this.toolCallId,
    this.title,
    this.status,
    this.rawInput,
    this.rawOutput,
    this.content,
    this.meta,
  });
}

/// The session mode changed on the agent side.
final class CurrentModeUpdate extends SessionUpdate {
  final String modeId;

  const CurrentModeUpdate(super.sessionId, this.modeId);
}

/// The agent pushed a full refresh of its `configOptions`.
final class ConfigOptionUpdate extends SessionUpdate {
  final List<Map<String, Object?>> configOptions;

  const ConfigOptionUpdate(super.sessionId, this.configOptions);
}

/// Any variant this client does not render (plans, commands, notices, ...).
final class UnknownSessionUpdate extends SessionUpdate {
  final String kind;
  final Map<String, Object?> raw;

  const UnknownSessionUpdate(super.sessionId, this.kind, this.raw);
}
