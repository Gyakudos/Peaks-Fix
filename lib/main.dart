import 'package:flutter/material.dart';

import 'app.dart';
import 'data/database.dart';
import 'window/window_chrome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowChrome.instance.init();
  await AppDatabase.instance.ensureSeeded();
  runApp(const VolaFixApp());
}
