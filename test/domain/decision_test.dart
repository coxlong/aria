import 'package:aria/domain/decision/decision.dart';
import 'package:flutter_test/flutter_test.dart';

Decision _decision(List<DecisionOption> options) => Decision(
  id: 'd1',
  prompt: 'Allow publishing the beta?',
  options: options,
  createdAt: DateTime(2026, 10, 24),
);

const DecisionOption _allowOnce = DecisionOption(
  id: 'a1',
  label: 'Allow once',
  kind: DecisionOptionKind.allowOnce,
);
const DecisionOption _allowAlways = DecisionOption(
  id: 'a2',
  label: 'Always allow',
  kind: DecisionOptionKind.allowAlways,
);
const DecisionOption _rejectOnce = DecisionOption(
  id: 'r1',
  label: 'Not now',
  kind: DecisionOptionKind.rejectOnce,
);
const DecisionOption _rejectAlways = DecisionOption(
  id: 'r2',
  label: 'Never allow',
  kind: DecisionOptionKind.rejectAlways,
);

void main() {
  test('offers the single sensible action first', () {
    final decision = _decision(<DecisionOption>[
      _rejectOnce,
      _allowAlways,
      _allowOnce,
    ]);

    expect(decision.primaryOption, _allowOnce);
  });

  test('always offers a way to decline', () {
    final decision = _decision(<DecisionOption>[_allowOnce, _rejectOnce]);
    expect(decision.declineOption, _rejectOnce);
  });

  test('a request with no reject option still yields a decline', () {
    final decision = _decision(<DecisionOption>[_allowOnce]);
    expect(decision.declineOption, isNull);
  });

  test('secondary options are neither primary nor decline', () {
    final decision = _decision(<DecisionOption>[
      _allowOnce,
      _rejectOnce,
      _allowAlways,
      _rejectAlways,
    ]);

    expect(decision.secondaryOptions, <DecisionOption>[
      _allowAlways,
      _rejectAlways,
    ]);
  });

  test('a decision is pending until answered', () {
    final decision = _decision(<DecisionOption>[_allowOnce]);
    expect(decision.isPending, isTrue);

    final answered = decision.copyWith(state: DecisionState.denied);
    expect(answered.isPending, isFalse);
  });

  test('unknown option kinds parse to other', () {
    expect(DecisionOptionKind.parse('something-new'), DecisionOptionKind.other);
    expect(
      DecisionOptionKind.parse('allow_always'),
      DecisionOptionKind.allowAlways,
    );
  });

  test('allowing is recorded as allowed and declining as denied', () {
    final decision = _decision(<DecisionOption>[_allowOnce, _rejectOnce]);

    expect(decision.resolve(_allowOnce).state, DecisionState.allowed);
    expect(decision.resolve(_rejectOnce).state, DecisionState.denied);
    expect(decision.resolve(_rejectOnce).chosenOptionId, 'r1');
  });

  test('answering nothing is a cancellation, not a decline', () {
    final resolved = _decision(<DecisionOption>[_allowOnce]).resolve(null);

    expect(resolved.state, DecisionState.cancelled);
    expect(resolved.chosenOptionId, isNull);
  });
}
