/// ACP method names used by the client.
abstract final class AcpMethods {
  // Client -> agent.
  static const String initialize = 'initialize';
  static const String authenticate = 'authenticate';
  static const String newSession = 'session/new';
  static const String loadSession = 'session/load';
  static const String listSessions = 'session/list';
  static const String prompt = 'session/prompt';
  static const String cancel = 'session/cancel';
  static const String closeSession = 'session/close';
  static const String setMode = 'session/set_mode';
  static const String setConfigOption = 'session/set_config_option';
  static const String setModel = 'session/set_model';

  // Agent -> client.
  static const String requestPermission = 'session/request_permission';
  static const String sessionUpdate = 'session/update';

  // Liveness.
  static const String ping = r'$/ping';
}

/// `session/update:sessionUpdate` discriminator values understood by Aria.
abstract final class SessionUpdateKind {
  static const String userMessageChunk = 'user_message_chunk';
  static const String agentMessageChunk = 'agent_message_chunk';
  static const String agentThoughtChunk = 'agent_thought_chunk';
  static const String toolCall = 'tool_call';
  static const String toolCallUpdate = 'tool_call_update';
  static const String currentModeUpdate = 'current_mode_update';
  static const String configOptionUpdate = 'config_option_update';
}
