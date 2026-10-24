import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'storage/preferences.dart';
import 'storage/secure_store.dart';

part 'providers.g.dart';

/// Overridden in `main()` with an instance loaded before the first frame.
@Riverpod(keepAlive: true)
AriaPreferences preferences(Ref ref) =>
    throw StateError('preferencesProvider must be overridden');

@Riverpod(keepAlive: true)
SecureStore secureStore(Ref ref) => SecureStore();
