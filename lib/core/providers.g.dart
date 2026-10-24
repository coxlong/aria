// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main()` with an instance loaded before the first frame.

@ProviderFor(preferences)
final preferencesProvider = PreferencesProvider._();

/// Overridden in `main()` with an instance loaded before the first frame.

final class PreferencesProvider
    extends
        $FunctionalProvider<AriaPreferences, AriaPreferences, AriaPreferences>
    with $Provider<AriaPreferences> {
  /// Overridden in `main()` with an instance loaded before the first frame.
  PreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesHash();

  @$internal
  @override
  $ProviderElement<AriaPreferences> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AriaPreferences create(Ref ref) {
    return preferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AriaPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AriaPreferences>(value),
    );
  }
}

String _$preferencesHash() => r'd04dd4cdee04a1c62d3a9e8c3b781cf630803c07';

@ProviderFor(secureStore)
final secureStoreProvider = SecureStoreProvider._();

final class SecureStoreProvider
    extends $FunctionalProvider<SecureStore, SecureStore, SecureStore>
    with $Provider<SecureStore> {
  SecureStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStoreHash();

  @$internal
  @override
  $ProviderElement<SecureStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecureStore create(Ref ref) {
    return secureStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureStore>(value),
    );
  }
}

String _$secureStoreHash() => r'4152faa8e5b4f3e77b4fbdc5fc1bb48f80b1a2d0';
