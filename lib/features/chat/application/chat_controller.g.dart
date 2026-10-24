// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives one open session: sends turns, folds executor events into an ordered
/// transcript, and settles the state at the end so nothing is left spinning.
///
/// The transcript starts empty. A resumed session replays its history through
/// the same event stream, so there is exactly one way a turn can appear.

@ProviderFor(Chat)
final chatProvider = ChatFamily._();

/// Drives one open session: sends turns, folds executor events into an ordered
/// transcript, and settles the state at the end so nothing is left spinning.
///
/// The transcript starts empty. A resumed session replays its history through
/// the same event stream, so there is exactly one way a turn can appear.
final class ChatProvider extends $NotifierProvider<Chat, ChatView> {
  /// Drives one open session: sends turns, folds executor events into an ordered
  /// transcript, and settles the state at the end so nothing is left spinning.
  ///
  /// The transcript starts empty. A resumed session replays its history through
  /// the same event stream, so there is exactly one way a turn can appear.
  ChatProvider._({
    required ChatFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatHash();

  @override
  String toString() {
    return r'chatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Chat create() => Chat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatView>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatHash() => r'077b6d73286caa9b694e7c0a2e804b88182b308a';

/// Drives one open session: sends turns, folds executor events into an ordered
/// transcript, and settles the state at the end so nothing is left spinning.
///
/// The transcript starts empty. A resumed session replays its history through
/// the same event stream, so there is exactly one way a turn can appear.

final class ChatFamily extends $Family
    with $ClassFamilyOverride<Chat, ChatView, ChatView, ChatView, String> {
  ChatFamily._()
    : super(
        retry: null,
        name: r'chatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives one open session: sends turns, folds executor events into an ordered
  /// transcript, and settles the state at the end so nothing is left spinning.
  ///
  /// The transcript starts empty. A resumed session replays its history through
  /// the same event stream, so there is exactly one way a turn can appear.

  ChatProvider call(String sessionId) =>
      ChatProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'chatProvider';
}

/// Drives one open session: sends turns, folds executor events into an ordered
/// transcript, and settles the state at the end so nothing is left spinning.
///
/// The transcript starts empty. A resumed session replays its history through
/// the same event stream, so there is exactly one way a turn can appear.

abstract class _$Chat extends $Notifier<ChatView> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  ChatView build(String sessionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ChatView, ChatView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatView, ChatView>,
              ChatView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
