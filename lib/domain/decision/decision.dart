import 'package:freezed_annotation/freezed_annotation.dart';

part 'decision.freezed.dart';
part 'decision.g.dart';

/// What an option does, mirroring the ACP permission option kinds.
enum DecisionOptionKind {
  allowOnce,
  allowAlways,
  rejectOnce,
  rejectAlways,
  other;

  static DecisionOptionKind parse(String kind) => switch (kind) {
    'allow_once' => DecisionOptionKind.allowOnce,
    'allow_always' => DecisionOptionKind.allowAlways,
    'reject_once' => DecisionOptionKind.rejectOnce,
    'reject_always' => DecisionOptionKind.rejectAlways,
    _ => DecisionOptionKind.other,
  };

  bool get isAllow =>
      this == DecisionOptionKind.allowOnce ||
      this == DecisionOptionKind.allowAlways;
}

/// One selectable outcome.
@freezed
abstract class DecisionOption with _$DecisionOption {
  const factory DecisionOption({
    required String id,
    required String label,
    required DecisionOptionKind kind,
  }) = _DecisionOption;

  factory DecisionOption.fromJson(Map<String, Object?> json) =>
      _$DecisionOptionFromJson(json);
}

/// Where a decision stands. A decision is answered exactly once.
enum DecisionState { pending, allowed, denied, cancelled }

/// Something only the person can settle.
///
/// A decision is raised by a running turn and answered once. It is never a
/// mode and never queued invisibly: while one is open, the agent waits.
@freezed
abstract class Decision with _$Decision {
  const factory Decision({
    required String id,
    required String prompt,
    required List<DecisionOption> options,
    required DateTime createdAt,
    @Default(DecisionState.pending) DecisionState state,
    String? detail,
    String? chosenOptionId,

    /// True when the action is irreversible or reaches outside the workspace.
    /// The approval sheet is then marked.
    @Default(false) bool highImpact,
  }) = _Decision;

  const Decision._();

  bool get isPending => state == DecisionState.pending;

  /// The single sensible action: the first allow option, when there is one.
  DecisionOption? get primaryOption {
    for (final option in options) {
      if (option.kind == DecisionOptionKind.allowOnce) return option;
    }
    for (final option in options) {
      if (option.kind.isAllow) return option;
    }
    return options.isEmpty ? null : options.first;
  }

  /// The way to decline. Never omit it.
  DecisionOption? get declineOption {
    for (final option in options) {
      if (option.kind == DecisionOptionKind.rejectOnce) return option;
    }
    for (final option in options) {
      if (!option.kind.isAllow) return option;
    }
    return null;
  }

  /// Every option that is neither the primary nor the decline action.
  List<DecisionOption> get secondaryOptions => options
      .where((option) => option != primaryOption && option != declineOption)
      .toList(growable: false);

  /// This decision with [option] recorded as the answer.
  ///
  /// Declining is a real answer, not a cancellation: the record has to show
  /// what actually happened when the card resolves. A null [option] is the
  /// separate "cancelled" outcome the protocol also allows.
  Decision resolve(DecisionOption? option) => copyWith(
    state: option == null
        ? DecisionState.cancelled
        : (option.kind.isAllow ? DecisionState.allowed : DecisionState.denied),
    chosenOptionId: option?.id,
  );
}
