import 'package:aria/core/models/server_profile.dart';
import 'package:aria/core/persistence/server_store.dart';
import 'package:aria/state/servers_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('starts empty', () async {
    final controller = ServersController(const ServerStore());
    await controller.load();

    expect(controller.loading, isFalse);
    expect(controller.servers, isEmpty);
  });

  test('saves a new server and persists its metadata', () async {
    final store = const ServerStore();
    final controller = ServersController(store);
    await controller.load();

    final saved = await controller.save(
      const ServerProfile(
        id: '',
        name: '  Work  ',
        url: ' ws://localhost:3000 ',
        token: '',
        cwd: '/tmp/work',
      ),
    );

    expect(saved.id, isNotEmpty);
    expect(saved.name, 'Work');
    expect(saved.url, 'ws://localhost:3000');
    expect(controller.servers, hasLength(1));

    final reloaded = ServersController(store);
    await reloaded.load();
    expect(reloaded.servers, hasLength(1));
    expect(reloaded.servers.single.name, 'Work');
    expect(reloaded.servers.single.url, 'ws://localhost:3000');
    // Secure storage is not available in unit tests, so the token is dropped
    // from the persisted metadata by design.
    expect(reloaded.servers.single.token, isEmpty);
  });

  test('edits an existing server in place', () async {
    final controller = ServersController(const ServerStore());
    await controller.load();
    final saved = await controller.save(
      const ServerProfile(
        id: '',
        name: 'One',
        url: 'ws://localhost:1',
        token: '',
        cwd: '/tmp',
      ),
    );

    final edited = await controller.save(
      saved.copyWith(name: 'Two', url: 'wss://localhost:2'),
    );

    expect(edited.id, saved.id);
    expect(controller.servers, hasLength(1));
    expect(controller.servers.single.name, 'Two');
    expect(controller.servers.single.url, 'wss://localhost:2');
  });

  test('deletes a server', () async {
    final store = const ServerStore();
    final controller = ServersController(store);
    await controller.load();
    final saved = await controller.save(
      const ServerProfile(
        id: '',
        name: 'One',
        url: 'ws://localhost:1',
        token: '',
        cwd: '/tmp',
      ),
    );

    await controller.delete(saved.id);

    expect(controller.servers, isEmpty);
    final reloaded = ServersController(store);
    await reloaded.load();
    expect(reloaded.servers, isEmpty);
  });
}
