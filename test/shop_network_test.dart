import 'dart:io';

import 'package:drift/native.dart';
import 'package:drift/remote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/database.dart';
import 'package:vola_fix/data/shop_network.dart';

void main() {
  test('generated keys are random and long enough', () {
    final a = NetworkSettings.generateKey();
    expect(a.length, 16);
    expect(a, isNot(NetworkSettings.generateKey()));
  });

  test('settings round-trip through json', () {
    const s = NetworkSettings(
      mode: NetworkMode.client,
      port: 9000,
      key: 'k',
      hostAddress: '10.0.0.2',
    );
    final back = NetworkSettings.fromJson(s.toJson());
    expect(back.mode, NetworkMode.client);
    expect(back.port, 9000);
    expect(back.hostAddress, '10.0.0.2');
  });

  test('client shares data with host over a websocket', () async {
    final server = DriftServer(NativeDatabase.memory());
    final host = await ShopHost.start(
      server: server,
      port: 0,
      key: 'secret',
      schemaVersion: AppDatabase.currentSchemaVersion,
    );
    addTearDown(host.stop);
    final settings = NetworkSettings(
      mode: NetworkMode.client,
      port: host.port,
      key: 'secret',
      hostAddress: '127.0.0.1',
    );
    final client = await connectToHost(settings);
    addTearDown(client.close);
    expect(await client.select(client.tickets).get(), isEmpty);
    expect(host.clientCount, 1);

    expect(
      connectToHost(settings.copyWith(key: 'wrong')),
      throwsA(isA<HostConnectionException>()),
    );
    expect(
        await HttpClient()
            .getUrl(Uri.parse('http://127.0.0.1:${host.port}'))
            .then((r) => r.close())
            .then((r) => r.statusCode),
        401);
  });
}
