/// Hand-written Agent Client Protocol (ACP) client.
///
/// The package is pure Dart: it does not depend on Flutter and uses only the
/// Dart SDK. The transport is the only place that touches `dart:io`.
library;

export 'src/client/acp_client.dart';
export 'src/models/config_surfaces.dart';
export 'src/models/content.dart';
export 'src/models/permission.dart';
export 'src/models/session.dart';
export 'src/models/session_update.dart';
export 'src/models/tool_call.dart';
export 'src/protocol/errors.dart';
export 'src/protocol/methods.dart';
export 'src/transport/acp_transport.dart';
export 'src/transport/ndjson.dart';
export 'src/transport/ws_transport.dart';
