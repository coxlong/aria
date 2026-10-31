// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'executor_factory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(executorFactory)
final executorFactoryProvider = ExecutorFactoryProvider._();

final class ExecutorFactoryProvider
    extends
        $FunctionalProvider<ExecutorFactory, ExecutorFactory, ExecutorFactory>
    with $Provider<ExecutorFactory> {
  ExecutorFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'executorFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$executorFactoryHash();

  @$internal
  @override
  $ProviderElement<ExecutorFactory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExecutorFactory create(Ref ref) {
    return executorFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExecutorFactory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExecutorFactory>(value),
    );
  }
}

String _$executorFactoryHash() => r'2a8473fb448d2e66c5d1c0193a0c142ca3a66e42';
