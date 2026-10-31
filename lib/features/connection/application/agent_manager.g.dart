// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns every agent connection and every conversation in the app.
///
/// Nothing here depends on a page being mounted. The manager subscribes to an
/// executor once, folds events into per-session state, and keeps that state
/// alive; pages only read it and send commands. That is what lets a running
/// turn survive leaving the conversation, keeps drafts per conversation, and
/// lets several agents stay connected at the same time.

@ProviderFor(AgentManager)
final agentManagerProvider = AgentManagerProvider._();

/// Owns every agent connection and every conversation in the app.
///
/// Nothing here depends on a page being mounted. The manager subscribes to an
/// executor once, folds events into per-session state, and keeps that state
/// alive; pages only read it and send commands. That is what lets a running
/// turn survive leaving the conversation, keeps drafts per conversation, and
/// lets several agents stay connected at the same time.
final class AgentManagerProvider
    extends $NotifierProvider<AgentManager, AgentManagerState> {
  /// Owns every agent connection and every conversation in the app.
  ///
  /// Nothing here depends on a page being mounted. The manager subscribes to an
  /// executor once, folds events into per-session state, and keeps that state
  /// alive; pages only read it and send commands. That is what lets a running
  /// turn survive leaving the conversation, keeps drafts per conversation, and
  /// lets several agents stay connected at the same time.
  AgentManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentManagerHash();

  @$internal
  @override
  AgentManager create() => AgentManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgentManagerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgentManagerState>(value),
    );
  }
}

String _$agentManagerHash() => r'b353d3f490d31a4ddb43397a49c124cc59df3bcb';

/// Owns every agent connection and every conversation in the app.
///
/// Nothing here depends on a page being mounted. The manager subscribes to an
/// executor once, folds events into per-session state, and keeps that state
/// alive; pages only read it and send commands. That is what lets a running
/// turn survive leaving the conversation, keeps drafts per conversation, and
/// lets several agents stay connected at the same time.

abstract class _$AgentManager extends $Notifier<AgentManagerState> {
  AgentManagerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AgentManagerState, AgentManagerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AgentManagerState, AgentManagerState>,
              AgentManagerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
