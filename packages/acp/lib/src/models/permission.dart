import 'tool_call.dart';

/// One selectable outcome in a permission request.
final class PermissionOption {
  /// `allow_once`, `allow_always`, `reject_once`, `reject_always`, or `other`.
  final String kind;
  final String name;
  final String optionId;

  const PermissionOption({
    required this.kind,
    required this.name,
    required this.optionId,
  });

  bool get isAllow => kind.startsWith('allow');

  factory PermissionOption.fromJson(Map<String, Object?> json) =>
      PermissionOption(
        kind: json['kind'] as String? ?? 'other',
        name: json['name'] as String? ?? 'Allow',
        optionId: json['optionId'] as String? ?? '',
      );
}

/// An agent request that MUST be answered exactly once.
///
/// [allow] and [deny] are idempotent after the first call: later calls return
/// immediately without sending a second response.
final class PermissionRequest {
  final String sessionId;
  final ToolCallInfo toolCall;
  final List<PermissionOption> options;
  final Future<void> Function(String? optionId) _respond;

  bool _answered = false;

  PermissionRequest({
    required this.sessionId,
    required this.toolCall,
    required this.options,
    required Future<void> Function(String? optionId) respond,
    // The callback is private to this library; a public field would leak it.
    // ignore: prefer_initializing_formals
  }) : _respond = respond;

  /// Whether a decision has already been sent.
  bool get isAnswered => _answered;

  /// Selects [optionId].
  Future<void> allow(String optionId) => _answer(optionId);

  /// Cancels the request (`outcome: cancelled`).
  Future<void> deny() => _answer(null);

  Future<void> _answer(String? optionId) {
    if (_answered) return Future<void>.value();
    _answered = true;
    return _respond(optionId);
  }
}
