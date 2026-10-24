import 'dart:convert';

/// Closes whatever markdown construct a streaming answer stopped in the middle
/// of.
///
/// An agent emits prose in chunks, so a turn can be rendered while the text ends
/// mid-fence, mid-bold, or mid-inline-code. Without repair the tail appears as
/// raw punctuation, which flickers back and forth on every chunk. Repairing is
/// cheaper and steadier than waiting for the next chunk.
///
/// Links are left alone: an unclosed `[` is rare mid-stream and closing it
/// wrongly is worse than showing it.
String healStreamingMarkdown(String text) {
  if (text.isEmpty) return text;

  if (_fences(text).isOdd) {
    // Everything after an unclosed fence is code; nothing else needs closing.
    final newline = text.endsWith('\n') ? '' : '\n';
    return '$text$newline```';
  }

  final prose = _withoutFences(text);
  // Emphasis inside inline code is content, not syntax: `**/*.dart` is one
  // glob, and closing a bold run it never opened would append characters the
  // author never wrote.
  final narrative = _withoutInlineCode(prose);
  final buffer = StringBuffer(text);
  if (_count(prose, '`').isOdd) buffer.write('`');
  if (_count(narrative, '**').isOdd) buffer.write('**');
  if (_count(narrative, '~~').isOdd) buffer.write('~~');
  return buffer.toString();
}

final RegExp _fence = RegExp(r'^\s*(```|~~~)');

int _fences(String text) {
  var count = 0;
  for (final line in const LineSplitter().convert(text)) {
    if (_fence.hasMatch(line)) count++;
  }
  return count;
}

/// Everything outside fenced blocks, so punctuation inside code is not counted.
String _withoutFences(String text) {
  final kept = <String>[];
  var inFence = false;
  for (final line in const LineSplitter().convert(text)) {
    if (_fence.hasMatch(line)) {
      inFence = !inFence;
      continue;
    }
    if (!inFence) kept.add(line);
  }
  return kept.join('\n');
}

/// The text with every inline code span removed, so only prose is inspected.
///
/// An unclosed backtick swallows the rest of the text, which is exactly what the
/// caller does too by closing it.
String _withoutInlineCode(String text) {
  final buffer = StringBuffer();
  var index = 0;
  while (index < text.length) {
    final open = text.indexOf('`', index);
    if (open < 0) {
      buffer.write(text.substring(index));
      break;
    }
    final close = text.indexOf('`', open + 1);
    buffer.write(text.substring(index, open));
    if (close < 0) break;
    buffer.write(' ');
    index = close + 1;
  }
  return buffer.toString();
}

int _count(String text, String token) {
  if (token.isEmpty) return 0;
  var count = 0;
  var index = text.indexOf(token);
  while (index >= 0) {
    count++;
    index = text.indexOf(token, index + token.length);
  }
  return count;
}
