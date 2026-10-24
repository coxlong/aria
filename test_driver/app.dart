import 'package:aria/main.dart' as app;
import 'package:flutter_driver/driver_extension.dart';

/// Entry point used only by the Flutter driver / MCP UI automation tools.
///
/// Run with `flutter run -d macos -t test_driver/app.dart`. The production
/// entry point is `lib/main.dart` and does not enable the driver extension.
Future<void> main() async {
  enableFlutterDriverExtension();
  await app.main();
}
