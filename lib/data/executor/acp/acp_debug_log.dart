import 'dart:io';

import 'package:flutter/foundation.dart';

/// Appends every ACP frame to one file so a debug run can be read afterwards.
///
/// The protocol package only hands frames out; where they land is a decision
/// for the app, which keeps `packages/acp` free of I/O and of logging policy.
final class AcpDebugLog {
  AcpDebugLog(this.file);

  /// The file frames are appended to.
  final File file;

  RandomAccessFile? _writer;

  /// Logs into the app's temporary directory, announcing the path once.
  factory AcpDebugLog.open() {
    final file = File('${Directory.systemTemp.path}/aria-acp.log');
    debugPrint('[aria] ACP frames → ${file.path}');
    return AcpDebugLog(file);
  }

  /// Matches the acp package's frame-log callback, so it can be handed over
  /// directly. One line per frame, direction first.
  ///
  /// Synchronous and flushed per line so the file can be tailed while the app
  /// runs; a broken transcript must never take the connection down with it.
  void call({required bool inbound, required String payload}) {
    try {
      final writer = _writer ??= file.openSync(mode: FileMode.append);
      writer.writeStringSync(
        '${DateTime.now().toIso8601String()} ${inbound ? '←' : '→'} $payload\n',
      );
      writer.flushSync();
    } on FileSystemException {
      // Debug aid only: drop the frame rather than disturb the session.
    }
  }

  void close() {
    try {
      _writer?.closeSync();
    } on FileSystemException {
      // Nothing to recover: the handle is going away either way.
    }
    _writer = null;
  }
}
