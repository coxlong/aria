import 'dart:convert';

/// Encodes a JSON-RPC message as one NDJSON frame.
String encodeNdjson(Map<String, Object?> message) => '${jsonEncode(message)}\n';

/// Incremental decoder for NDJSON text.
///
/// Handles three wire realities: one chunk may carry several lines, one line
/// may be split across chunks, and the final line may arrive without a
/// trailing newline.
final class NdjsonDecoder {
  final StringBuffer _buffer = StringBuffer();

  /// Feeds [chunk] and returns every complete line it produced.
  List<String> add(String chunk) {
    _buffer.write(chunk);
    final text = _buffer.toString();
    final out = <String>[];
    var start = 0;

    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) != 0x0A) continue;
      final line = text.substring(start, i).trim();
      if (line.isNotEmpty) out.add(line);
      start = i + 1;
    }

    _buffer
      ..clear()
      ..write(text.substring(start));
    return out;
  }

  /// Flushes a trailing line that is already complete JSON but has no newline.
  ///
  /// Returns an empty list when the buffer holds an incomplete frame; that
  /// frame stays buffered until the next chunk.
  List<String> flushIfComplete() {
    final tail = _buffer.toString().trim();
    if (tail.isEmpty) {
      _buffer.clear();
      return const [];
    }
    if (!_looksLikeCompleteJson(tail)) return const [];
    _buffer.clear();
    return [tail];
  }

  /// Discards any buffered partial frame.
  ///
  /// Called after a reconnect so a dead socket's half-written line cannot
  /// corrupt the first frame of the new stream.
  void reset() => _buffer.clear();

  static bool _looksLikeCompleteJson(String text) {
    final first = text.codeUnitAt(0);
    final last = text.codeUnitAt(text.length - 1);
    final startsOk = first == 0x7B || first == 0x5B; // { or [
    final endsOk = last == 0x7D || last == 0x5D; // } or ]
    if (!startsOk || !endsOk) return false;
    try {
      jsonDecode(text);
      return true;
    } on FormatException {
      return false;
    }
  }
}
