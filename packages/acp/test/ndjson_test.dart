import 'package:acp/acp.dart';
import 'package:test/test.dart';

void main() {
  group('NdjsonDecoder', () {
    test('parses one complete line', () {
      final decoder = NdjsonDecoder();
      expect(decoder.add('{"a":1}\n'), <String>['{"a":1}']);
    });

    test('parses several lines from one chunk', () {
      final decoder = NdjsonDecoder();
      expect(decoder.add('{"a":1}\n{"b":2}\n'), <String>['{"a":1}', '{"b":2}']);
    });

    test('buffers a line split across chunks', () {
      final decoder = NdjsonDecoder();
      expect(decoder.add('{"a":'), isEmpty);
      expect(decoder.add('1}\n'), <String>['{"a":1}']);
    });

    test('keeps a partial tail buffered', () {
      final decoder = NdjsonDecoder();
      expect(decoder.add('{"a":1}\n{"b":'), <String>['{"a":1}']);
      expect(decoder.add('2}\n'), <String>['{"b":2}']);
    });

    test('flushes a complete trailing line without a newline', () {
      final decoder = NdjsonDecoder();
      expect(decoder.add('{"a":1}'), isEmpty);
      expect(decoder.flushIfComplete(), <String>['{"a":1}']);
    });

    test('does not flush an incomplete trailing line', () {
      final decoder = NdjsonDecoder();
      expect(decoder.add('{"a":'), isEmpty);
      expect(decoder.flushIfComplete(), isEmpty);
      expect(decoder.add('1}'), isEmpty);
      expect(decoder.flushIfComplete(), <String>['{"a":1}']);
    });

    test('does not flush a complete-looking but malformed line', () {
      final decoder = NdjsonDecoder();
      expect(decoder.add('{"a":}'), isEmpty);
      expect(decoder.flushIfComplete(), isEmpty);

      decoder.reset();
      expect(decoder.add('abc}'), isEmpty);
      expect(decoder.flushIfComplete(), isEmpty);
    });

    test('reset drops a partial frame', () {
      final decoder = NdjsonDecoder();
      decoder.add('{"a":');
      decoder.reset();
      expect(decoder.add('{"b":2}\n'), <String>['{"b":2}']);
    });

    test('ignores blank lines', () {
      final decoder = NdjsonDecoder();
      expect(decoder.add('\n\n{"a":1}\n'), <String>['{"a":1}']);
    });
  });
}
