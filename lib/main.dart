import 'package:flutter/material.dart';

import 'data/shop_network.dart';
import 'main_startup.dart';
import 'window/window_chrome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowChrome.instance.init();
  await _start();
}

Future<void> _start() async {
  var settings = await NetworkSettings.load();
  final problem = await openConfiguredDatabase(settings);
  if (problem == null) {
    runShop();
    return;
  }
  runApp(
    HostUnavailableApp(
      message: problem,
      onRetry: _start,
      onUseLocal: () async {
        settings = settings.copyWith(mode: NetworkMode.standalone);
        await settings.save();
        await _start();
      },
    ),
  );
}
