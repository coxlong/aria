// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Aria has one entrance and two surfaces: home, and one conversation.
///
/// A connection is not a conversation: home opens as soon as an agent answers,
/// and a session exists only once a conversation is opened. Every connected
/// agent keeps running in the background; the router only follows the active
/// one. Settings and agent configuration live in sheets, not routes, so the
/// back stack only means one thing.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Aria has one entrance and two surfaces: home, and one conversation.
///
/// A connection is not a conversation: home opens as soon as an agent answers,
/// and a session exists only once a conversation is opened. Every connected
/// agent keeps running in the background; the router only follows the active
/// one. Settings and agent configuration live in sheets, not routes, so the
/// back stack only means one thing.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Aria has one entrance and two surfaces: home, and one conversation.
  ///
  /// A connection is not a conversation: home opens as soon as an agent answers,
  /// and a session exists only once a conversation is opened. Every connected
  /// agent keeps running in the background; the router only follows the active
  /// one. Settings and agent configuration live in sheets, not routes, so the
  /// back stack only means one thing.
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

String _$appRouterHash() => r'bb23526f3dc3354565f7f6ce0c5ed36e0e6c6ecd';
