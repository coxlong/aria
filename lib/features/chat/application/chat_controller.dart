import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/app_error.dart';
import '../../../domain/chat/chat_turn.dart';
import '../../../domain/chat/work_step.dart';
import '../../../domain/executor/executor.dart';
import '../../connection/application/connection_controller.dart';
import 'chat_view.dart';

part 'chat_controller.g.dart';

/// Drives one open session: sends turns, folds executor events into an ordered
/// transcript, and settles the state at the end so nothing is left spinning.
///
/// The transcript starts empty. A resumed session replays its history through
/// the same event stream, so there is exactly one way a turn can appear.
@riverpod
class Chat extends _$Chat {
  static const Uuid _ids = Uuid();

  /// Blocks are batched at roughly one frame; a chunk-per-state-update rebuilds
  /// the list far faster than it can be painted.
  static const Duration _flushInterval = Duration(milliseconds: 24);

  /// How long a cancelled turn may stay silent before it is settled anyway.
  static const Duration _stopGrace = Duration(seconds: 10);

  StreamSubscription<ExecutorEvent>? _events;
  Timer? _flushTimer;
  Timer? _stopGuard;
  bool _disposed = false;

  final List<ChatTurn> _finished = <ChatTurn>[];
  final List<TurnBlock> _blocks = <TurnBlock>[];
  ChatTurn? _live;
  int _proseSeq = 0;
  bool _awaitingEcho = false;

  @override
  ChatView build(String sessionId) {
    final executor = ref.read(connectionProvider.notifier).executor;

    ref.onDispose(() {
      _disposed = true;
      _flushTimer?.cancel();
      _stopGuard?.cancel();
      final subscription = _events;
      if (subscription != null) unawaited(subscription.cancel());
    });

    if (executor != null) {
      _events = executor.events.listen((event) {
        if (event.sessionId == sessionId) _onEvent(event);
      });
      // Attaching after listening is what makes a resumed session's replay
      // arrive somewhere it can be rendered.
      executor.attach(sessionId);
    }

    return ChatView(sessionId: sessionId);
  }

  // ── Turns ───────────────────────────────────────────────────────────────

  /// Sends a turn. Returns whether it was accepted, so the composer knows
  /// whether it may clear its draft.
  Future<bool> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.running) return false;

    final executor = ref.read(connectionProvider.notifier).executor;
    if (executor == null) {
      state = state.copyWith(error: const UnknownFailure('Not connected'));
      return false;
    }

    _startTurn(trimmed);
    _awaitingEcho = true;
    _publish(running: true, error: null);

    // Not awaited: a prompt resolves only at the stop reason, which may be a
    // long time, and progress arrives on the event stream.
    unawaited(executor.prompt(sessionId: state.sessionId, text: trimmed));
    return true;
  }

  /// Stops the running turn, keeping whatever was already produced.
  Future<void> stop() async {
    if (!state.running) return;
    final executor = ref.read(connectionProvider.notifier).executor;
    if (executor == null) return;

    state = state.copyWith(stopping: true);

    _stopGuard?.cancel();
    _stopGuard = Timer(_stopGrace, () {
      _stopGuard = null;
      if (_disposed) return;
      if (state.running) _finishTurn();
    });

    try {
      await executor.cancel(state.sessionId);
    } on Object catch (failure) {
      _fail(AppError.from(failure));
    }
  }

  // ── Executor events ─────────────────────────────────────────────────────

  void _onEvent(ExecutorEvent event) {
    if (_disposed) return;
    switch (event) {
      case UserPrompt(:final text):
        // A live turn is opened by `send`; the only user message that starts a
        // new turn here is one the agent replays as history.
        if (_awaitingEcho) {
          _awaitingEcho = false;
        } else {
          _startTurn(text);
          _publish();
        }
      case AgentText(:final text):
        _appendText(text);
      case AgentThought(:final text):
        _appendThought(text);
      case StepChanged(:final step):
        _applyStep(step);
      case ExecutionFinished(:final stopReason):
        _finishTurn(stopReason: stopReason);
      case ExecutionFailed(:final error):
        _fail(error);
      case DecisionRaised():
      case SurfacesChanged():
        break;
    }
  }

  void _startTurn(String userText) {
    final previous = _live;
    if (previous != null) {
      // Starting a new turn ends whatever was still live. A replayed turn never
      // receives a finish event, so without this it would keep claiming to be
      // running for the rest of the session.
      _finished.add(
        previous.copyWith(blocks: List<TurnBlock>.of(_blocks), running: false),
      );
    }
    _live = ChatTurn(id: _ids.v4(), userText: userText, running: true);
    _blocks.clear();
  }

  void _appendText(String text) {
    _ensureTurn();
    final last = _blocks.isEmpty ? null : _blocks.last;
    if (last is TextBlock) {
      _blocks[_blocks.length - 1] = TextBlock(
        id: last.id,
        text: last.text + text,
      );
    } else {
      _blocks.add(TextBlock(id: 'prose-${_proseSeq++}', text: text));
    }
    _scheduleFlush();
  }

  void _appendThought(String text) {
    _ensureTurn();
    final last = _blocks.isEmpty ? null : _blocks.last;
    if (last is ThoughtBlock) {
      _blocks[_blocks.length - 1] = ThoughtBlock(
        id: last.id,
        text: last.text + text,
      );
    } else {
      _blocks.add(ThoughtBlock(id: 'thought-${_proseSeq++}', text: text));
    }
    _scheduleFlush();
  }

  void _applyStep(WorkStep step) {
    _ensureTurn();
    final now = DateTime.now();
    final index = _blocks.indexWhere(
      (block) => block is ToolBlock && block.step.id == step.id,
    );

    if (index < 0) {
      _blocks.add(
        ToolBlock(
          step: step.copyWith(
            startedAt: step.startedAt ?? now,
            endedAt: step.status.isTerminal ? (step.endedAt ?? now) : null,
          ),
        ),
      );
    } else {
      final previous = (_blocks[index] as ToolBlock).step;
      _blocks[index] = ToolBlock(
        step: step.copyWith(
          startedAt: previous.startedAt ?? now,
          endedAt: step.status.isTerminal ? (previous.endedAt ?? now) : null,
        ),
      );
    }
    _scheduleFlush();
  }

  void _ensureTurn() {
    if (_live != null) return;
    _live = ChatTurn(id: _ids.v4(), userText: '', running: true);
  }

  void _finishTurn({String? stopReason}) {
    _flushTimer?.cancel();
    _flushTimer = null;
    _stopGuard?.cancel();
    _stopGuard = null;
    _awaitingEcho = false;

    final live = _live;
    if (live != null) {
      _live = live.copyWith(blocks: <TurnBlock>[..._blocks], running: false);
    }
    _publish(running: false, stopping: false, error: _stopError(stopReason));
  }

  /// The stop reasons that mean the turn did not finish on its own terms.
  ///
  /// `end_turn` and `cancelled` are the two ordinary outcomes; everything else
  /// is reported to the person instead of being shown as a complete answer.
  static AppError? _stopError(String? stopReason) {
    if (stopReason == null) return null;
    return switch (stopReason) {
      'error' || 'refusal' || 'max_tokens' => ExecutionStopped(stopReason),
      _ => null,
    };
  }

  void _fail(AppError error) {
    _flushTimer?.cancel();
    _flushTimer = null;
    _stopGuard?.cancel();
    _stopGuard = null;
    _awaitingEcho = false;

    final live = _live;
    if (live != null) {
      _live = live.copyWith(blocks: <TurnBlock>[..._blocks], running: false);
    }
    _publish(running: false, stopping: false, error: error);
  }

  // ── Publishing ──────────────────────────────────────────────────────────

  void _scheduleFlush() {
    if (_flushTimer != null) return;
    _flushTimer = Timer(_flushInterval, () {
      _flushTimer = null;
      _publish();
    });
  }

  void _publish({bool? running, bool? stopping, AppError? error}) {
    if (_disposed) return;

    final live = _live;
    final turns = <ChatTurn>[
      ..._finished,
      if (live != null) live.copyWith(blocks: <TurnBlock>[..._blocks]),
    ];
    state = state.copyWith(
      turns: turns,
      running: running ?? state.running,
      stopping: stopping ?? state.stopping,
      error: error,
    );
  }
}
