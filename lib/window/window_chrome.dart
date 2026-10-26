import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridge to the native window shell in `windows/runner/flutter_window.cpp`.
///
/// Only meaningful on Windows: every member is a safe no-op on other
/// platforms, so the same widget tree can run on Android.
class WindowChrome extends ChangeNotifier {
  WindowChrome._();

  static final WindowChrome instance = WindowChrome._();

  static const MethodChannel _channel = MethodChannel('vola/window');

  /// Whether the native implementation of this channel exists.
  static final bool isSupported = Platform.isWindows;

  bool _isMaximized = false;

  bool get isMaximized => _isMaximized;

  /// Subscribes to native notifications and reads the initial state. Call once
  /// after `WidgetsFlutterBinding.ensureInitialized()` and before `runApp`.
  Future<void> init() async {
    if (!isSupported) {
      return;
    }
    _channel.setMethodCallHandler(_handleNativeCall);
    _isMaximized = await _channel.invokeMethod<bool>('isMaximized') ?? false;
    notifyListeners();
  }

  /// Starts a native window move. Call from a drag gesture in the title bar.
  Future<void> startDrag() => _invoke('startDrag');

  Future<void> minimize() => _invoke('minimize');

  Future<void> toggleMaximize() => _invoke('toggleMaximize');

  Future<void> close() => _invoke('close');

  Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method == 'maximizedChanged') {
      final maximized = call.arguments as bool? ?? false;
      if (maximized == _isMaximized) {
        return;
      }
      _isMaximized = maximized;
      notifyListeners();
    }
  }

  Future<void> _invoke(String method) async {
    if (!isSupported) {
      return;
    }
    await _channel.invokeMethod<void>(method);
  }
}
