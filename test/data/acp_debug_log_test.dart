import 'dart:io';

import 'package:aria/data/executor/acp/acp_debug_log.dart';
import 'package:flutter_test/flutter_test.dart';

/// The transcript is what makes a wire-level bug visible after the fact, so
/// both directions and the frame text itself have to reach the file.
void main() {
  test('appends one line per frame, in both directions', () async {
    final dir = await Directory.systemTemp.createTemp('acp-debug-log');
    addTearDown(() => dir.delete(recursive: true));
    final log = AcpDebugLog(File('${dir.path}/frames.log'));

    log(inbound: true, payload: '{"sessionUpdate":"tool_call"}');
    log(inbound: false, payload: '{"method":"session/prompt"}');
    log.close();

    final lines = await log.file.readAsLines();
    expect(lines, hasLength(2));
    expect(lines[0], endsWith('← {"sessionUpdate":"tool_call"}'));
    expect(lines[1], endsWith('→ {"method":"session/prompt"}'));
  });
}
