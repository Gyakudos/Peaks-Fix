import 'package:flutter/material.dart';

import 'app.dart';
import 'data/database.dart';
import 'shell/app_access.dart';
import 'window/window_chrome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowChrome.instance.init();
  await AppDatabase.instance.ensureSeeded();
  runApp(
    VolaFixApp(loadAccounts: () => loadStaffAccounts(AppDatabase.instance)),
  );
}
