// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Aria has one entry and one workspace.
///
/// The app always opens on the server list; a session exists only after a
/// connection succeeds, and losing it sends the person back to that list. There
/// is no way to reach the chat surface without a live session, which is exactly
/// the state the old home screen could not guarantee.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Aria has one entry and one workspace.
///
/// The app always opens on the server list; a session exists only after a
/// connection succeeds, and losing it sends the person back to that list. There
/// is no way to reach the chat surface without a live session, which is exactly
/// the state the old home screen could not guarantee.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Aria has one entry and one workspace.
  ///
  /// The app always opens on the server list; a session exists only after a
  /// connection succeeds, and losing it sends the person back to that list. There
  /// is no way to reach the chat surface without a live session, which is exactly
  /// the state the old home screen could not guarantee.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'915b976638efd6c8d66d83b5e1668689c88b8437';
