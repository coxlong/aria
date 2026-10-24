import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/storage/preferences.dart';

/// Everything the first frame needs is loaded before `runApp`; nothing on the
/// first screen waits on the network.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final shared = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(AriaPreferences(shared)),
      ],
      child: const AriaApp(),
    ),
  );
}
