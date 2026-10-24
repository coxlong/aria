import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:acp/acp.dart';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

Future<void> waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late HttpServer server;
  late Uri wsUri;
  late List<WebSocket> sockets;
  late List<String> received;
  late List<HttpHeaders> capturedHeaders;

  setUp(() async {
    sockets = <WebSocket>[];
    received = <String>[];
    capturedHeaders = <HttpHeaders>[];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    wsUri = Uri.parse('ws://127.0.0.1:${server.port}/');
    server.listen((request) async {
      capturedHeaders.add(request.headers);
      final socket = await WebSocketTransformer.upgrade(
        request,
        protocolSelector: (protocols) =>
            protocols.contains(WsTransport.subprotocol)
            ? WsTransport.subprotocol
            : null,
      );
      socket.listen((data) => received.add(data as String));
      sockets.add(socket);
    });
  });

  tearDown(() async {
    for (final socket in sockets) {
      await socket.close();
    }
    await server.close(force: true);
  });

  test('sends auth headers and requests the acp.v1 subprotocol', () async {
    final transport = await WsTransport.connect(
      wsUri,
      token: 'secret',
      heartbeatInterval: const Duration(hours: 1),
    );
    addTearDown(transport.close);

    await waitFor(() => sockets.isNotEmpty);
    final headers = capturedHeaders.single;
    expect(headers.value(HttpHeaders.authorizationHeader), 'Bearer secret');
    expect(
      headers.value('sec-websocket-protocol'),
      contains(WsTransport.subprotocol),
    );
    expect(transport.state, AcpTransportState.connected);
  });

  test('filters bridge preambles and captures the client id', () async {
    final clientIds = <String>[];
    final transport = await WsTransport.connect(
      wsUri,
      onClientId: clientIds.add,
      heartbeatInterval: const Duration(hours: 1),
    );
    addTearDown(transport.close);

    final frames = <String>[];
    transport.frames.listen(frames.add);

    await waitFor(() => sockets.isNotEmpty);
    sockets.single.add('{"type":"connected","clientId":"cid-1"}');
    await waitFor(() => clientIds.isNotEmpty);

    expect(clientIds.single, 'cid-1');
    expect(transport.clientId, 'cid-1');
    expect(frames, isEmpty, reason: 'preamble must not reach the protocol');

    sockets.single.add('{"type":"connected",\n');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(frames, isEmpty, reason: 'malformed preambles are dropped');
  });

  test('reassembles a line split across websocket messages', () async {
    final transport = await WsTransport.connect(
      wsUri,
      heartbeatInterval: const Duration(hours: 1),
    );
    addTearDown(transport.close);

    final frames = <String>[];
    transport.frames.listen(frames.add);

    await waitFor(() => sockets.isNotEmpty);
    sockets.single.add('{"jsonrpc":"2.0","id"');
    sockets.single.add(':1,"result":{}}\n');
    await waitFor(() => frames.isNotEmpty);

    expect(frames.single, '{"jsonrpc":"2.0","id":1,"result":{}}');
  });

  test(
    'reconnects and flushes frames queued while the socket is down',
    () async {
      final transport = await WsTransport.connect(
        wsUri,
        heartbeatInterval: const Duration(hours: 1),
        policy: const ReconnectPolicy(
          initialDelay: Duration(milliseconds: 20),
          maxDelay: Duration(milliseconds: 50),
        ),
      );
      addTearDown(transport.close);

      final states = <AcpTransportState>[];
      transport.states.listen(states.add);

      await waitFor(() => sockets.length == 1);
      await transport.send('{"jsonrpc":"2.0","id":1,"method":"a"}');
      await waitFor(
        () => received.any((line) => line.contains('"method":"a"')),
      );

      await sockets.single.close();
      await waitFor(() => states.contains(AcpTransportState.reconnecting));

      await transport.send('{"jsonrpc":"2.0","id":2,"method":"b"}');
      await waitFor(() => sockets.length == 2);
      await waitFor(
        () => received.any((line) => line.contains('"method":"b"')),
      );
    },
  );

  test('sends \$/ping heartbeats', () async {
    final transport = await WsTransport.connect(
      wsUri,
      heartbeatInterval: const Duration(milliseconds: 30),
    );
    addTearDown(transport.close);

    await waitFor(() => sockets.isNotEmpty);
    await waitFor(() => received.any((line) => line.contains(r'$/ping')));
  });

  test('times out when the handshake never completes', () async {
    final silent = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final accepted = <Socket>[];
    silent.listen(accepted.add);
    addTearDown(() async {
      for (final socket in accepted) {
        socket.destroy();
      }
      await silent.close();
    });

    await expectLater(
      WsTransport.connect(
        Uri.parse('ws://127.0.0.1:${silent.port}/'),
        connectTimeout: const Duration(milliseconds: 100),
      ),
      throwsA(isA<AcpProtocolError>()),
    );
  });

  test('keeps retrying when a reconnect attempt fails', () async {
    final transport = await WsTransport.connect(
      wsUri,
      heartbeatInterval: const Duration(hours: 1),
      policy: const ReconnectPolicy(
        initialDelay: Duration(milliseconds: 20),
        maxDelay: Duration(milliseconds: 20),
      ),
    );
    addTearDown(transport.close);

    final states = <AcpTransportState>[];
    transport.states.listen(states.add);
    await waitFor(() => sockets.length == 1);

    await sockets.single.close();
    await server.close(force: true);
    await waitFor(
      () =>
          states
              .where((state) => state == AcpTransportState.reconnecting)
              .length >=
          2,
      timeout: const Duration(seconds: 2),
    );
  });

  test('drops the oldest frame when the outbox overflows', () async {
    final transport = await WsTransport.connect(
      wsUri,
      heartbeatInterval: const Duration(hours: 1),
      policy: const ReconnectPolicy(
        initialDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 1),
        maxOutboxFrames: 1,
      ),
    );
    addTearDown(transport.close);

    await waitFor(() => sockets.length == 1);
    await sockets.single.close();
    await waitFor(() => transport.state == AcpTransportState.reconnecting);

    await transport.send('{"id":1}');
    await transport.send('{"id":2}');

    await waitFor(() => sockets.length == 2);
    await waitFor(() => received.any((line) => line.contains('"id":2')));
    expect(received.any((line) => line.contains('"id":1')), isFalse);
  });

  test('abrupt socket loss schedules a reconnect', () async {
    const websocketGuid = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
    final rawServer = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final connections = <Socket>[];
    rawServer.listen((socket) {
      connections.add(socket);
      var handshakeDone = false;
      socket.listen((data) {
        if (handshakeDone) return;
        handshakeDone = true;
        final request = latin1.decode(data);
        var key = '';
        for (final line in request.split('\r\n')) {
          if (line.toLowerCase().startsWith('sec-websocket-key:')) {
            key = line.substring('sec-websocket-key:'.length).trim();
          }
        }
        final accept = base64.encode(
          sha1.convert(utf8.encode('$key$websocketGuid')).bytes,
        );
        socket.write(
          'HTTP/1.1 101 Switching Protocols\r\n'
          'Upgrade: websocket\r\n'
          'Connection: Upgrade\r\n'
          'Sec-WebSocket-Accept: $accept\r\n'
          'Sec-WebSocket-Protocol: acp.v1\r\n'
          '\r\n',
        );
        // Drop the TCP connection abruptly: the client should surface a
        // stream error (not only a clean close) and reconnect.
        Timer(const Duration(milliseconds: 50), socket.destroy);
      }, onError: (Object _) {});
    });
    addTearDown(() async {
      for (final socket in connections) {
        socket.destroy();
      }
      await rawServer.close();
    });

    final transport = await WsTransport.connect(
      Uri.parse('ws://127.0.0.1:${rawServer.port}/'),
      heartbeatInterval: const Duration(hours: 1),
      policy: const ReconnectPolicy(
        initialDelay: Duration(milliseconds: 20),
        maxDelay: Duration(milliseconds: 20),
      ),
    );
    addTearDown(transport.close);

    final states = <AcpTransportState>[];
    transport.states.listen(states.add);
    await waitFor(
      () => states.contains(AcpTransportState.reconnecting),
      timeout: const Duration(seconds: 2),
    );
  });

  test('throws when the first connection fails', () async {
    await expectLater(
      WsTransport.connect(
        Uri.parse('ws://127.0.0.1:1/'),
        connectTimeout: const Duration(milliseconds: 300),
      ),
      throwsA(anything),
    );
  });
}
