// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the agent connection: one client, one open session, one session list.
///
/// Nothing else in the app creates an [Executor] or talks to the protocol.

@ProviderFor(Connection)
final connectionProvider = ConnectionProvider._();

/// Owns the agent connection: one client, one open session, one session list.
///
/// Nothing else in the app creates an [Executor] or talks to the protocol.
final class ConnectionProvider
    extends $NotifierProvider<Connection, ConnectionSnapshot> {
  /// Owns the agent connection: one client, one open session, one session list.
  ///
  /// Nothing else in the app creates an [Executor] or talks to the protocol.
  ConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionHash();

  @$internal
  @override
  Connection create() => Connection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectionSnapshot value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectionSnapshot>(value),
    );
  }
}

String _$connectionHash() => r'6c6baa495aa3689156ddb4ae571311a7ff3388e6';

/// Owns the agent connection: one client, one open session, one session list.
///
/// Nothing else in the app creates an [Executor] or talks to the protocol.

abstract class _$Connection extends $Notifier<ConnectionSnapshot> {
  ConnectionSnapshot build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ConnectionSnapshot, ConnectionSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConnectionSnapshot, ConnectionSnapshot>,
              ConnectionSnapshot,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
