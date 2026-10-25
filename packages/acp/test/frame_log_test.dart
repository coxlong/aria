import 'dart:convert';

import 'package:acp/acp.dart';
import 'package:test/test.dart';

import 'support/fake_transport.dart';

/// The transcript hook is the only way to see what went over the wire: the
/// parsed models deliberately drop fields the app does not render.
void main() {
  test('reports outbound and inbound frames verbatim', () async {
    final transport = FakeTransport();
    final logged = <(bool, String)>[];
    final client = AcpClient(
      transport,
      onFrameLog: ({required bool inbound, required String payload}) =>
          logged.add((inbound, payload)),
    );
    addTearDown(client.close);

    final initializing = client.initialize();
    expect(logged, hasLength(1));
    expect(logged.single.$1, isFalse);
    expect(logged.single.$2, jsonEncode(transport.lastSent));

    transport.emit(<String, Object?>{
      'jsonrpc': '2.0',
      'id': transport.lastSent['id'],
      'result': <String, Object?>{'protocolVersion': 1},
    });
    await initializing;

    expect(logged, hasLength(2));
    expect(logged.last.$1, isTrue);
    expect(logged.last.$2, contains('"protocolVersion":1'));
  });

  test('logs a malformed frame before dropping it', () {
    final transport = FakeTransport();
    final logged = <(bool, String)>[];
    final client = AcpClient(
      transport,
      onFrameLog: ({required bool inbound, required String payload}) =>
          logged.add((inbound, payload)),
    );
    addTearDown(client.close);

    transport.emitRaw('not json');

    expect(logged, <(bool, String)>[(true, 'not json')]);
  });
}
