import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_session.freezed.dart';

/// What this connection can do, decided once at `initialize`.
@freezed
abstract class AgentCapabilities with _$AgentCapabilities {
  const factory AgentCapabilities({
    @Default(false) bool canLoadSession,
    @Default(false) bool canListSessions,
    @Default(false) bool canDeleteSession,
  }) = _AgentCapabilities;
}

/// A session the agent knows about, from `session/list`.
///
/// Aria never caches this list: the agent is the only source of truth for which
/// sessions exist.
@freezed
abstract class AgentSessionSummary with _$AgentSessionSummary {
  const factory AgentSessionSummary({
    required String id,
    @Default('') String cwd,
    @Default('') String title,
    DateTime? updatedAt,
  }) = _AgentSessionSummary;

  const AgentSessionSummary._();

  bool get hasTitle => title.trim().isNotEmpty;
}

/// The session this client is attached to right now.
@freezed
abstract class AgentSession with _$AgentSession {
  const factory AgentSession({required String id, required String cwd}) =
      _AgentSession;
}

/// One value a session can be switched to: a model, a mode, an effort level.
@freezed
abstract class SessionOption with _$SessionOption {
  const factory SessionOption({required String id, required String label}) =
      _SessionOption;
}

/// Everything the agent advertised for the open session.
///
/// Agents disagree about how they publish these, so the executor normalises
/// them here and the interface never sees the protocol shapes.
@freezed
abstract class SessionSurfaces with _$SessionSurfaces {
  const factory SessionSurfaces({
    @Default(<SessionOption>[]) List<SessionOption> models,
    String? currentModelId,
    @Default(<SessionOption>[]) List<SessionOption> modes,
    String? currentModeId,
    @Default(<SessionOption>[]) List<SessionOption> efforts,
    String? currentEffortValue,

    /// The config id effort levels are written back to, when the agent uses the
    /// `configOptions` shape.
    String? effortConfigId,
  }) = _SessionSurfaces;

  const SessionSurfaces._();

  static const SessionSurfaces none = SessionSurfaces();

  bool get hasModels => models.isNotEmpty;
  bool get hasModes => modes.isNotEmpty;
  bool get hasEfforts => efforts.isNotEmpty;

  /// The label to show on the composer chip, or null when the agent did not say
  /// what is selected.
  String? get modelLabel => _labelOf(models, currentModelId);
  String? get modeLabel => _labelOf(modes, currentModeId);
  String? get effortLabel => _labelOf(efforts, currentEffortValue);

  /// The label of [current] in [options], or null when it is unknown.
  ///
  /// Guessing the first entry would present a model the agent never claimed as
  /// active; the chip falls back to its generic name instead.
  static String? _labelOf(List<SessionOption> options, String? current) {
    if (current == null) return null;
    for (final option in options) {
      if (option.id == current) return option.label;
    }
    return null;
  }
}
