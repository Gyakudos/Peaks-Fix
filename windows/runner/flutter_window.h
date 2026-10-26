#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/encodable_value.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/method_result.h>

#include <memory>
#include <optional>
#include <string>

#include "tray_icon.h"
#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // Registers the |vola/window| method channel used by the Flutter title bar.
  void CreateMethodChannel();
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // Window commands shared by the method channel, the tray menu and system
  // messages.
  void Minimize();
  void ToggleMaximize();
  void ShowFromTray();
  void HideToTray();

  void NotifyMaximizedChanged(bool maximized);

  // Handles the messages that make the window frameless and manually
  // resizable. Returns std::nullopt when the message should fall through to
  // the default implementation.
  std::optional<LRESULT> HandleCustomFrameMessage(HWND window,
                                                  UINT const message,
                                                  WPARAM const wparam,
                                                  LPARAM const lparam);

  void CreateTrayIcon();
  void HandleTrayMessage(HWND window, LPARAM lparam);

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // The channel backing lib/window/window_chrome.dart.
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      method_channel_;

  TrayIcon tray_icon_;
  HICON tray_icon_handle_ = nullptr;

  // Registered "TaskbarCreated" message id, 0 until the tray icon is created.
  UINT taskbar_created_message_ = 0;

  // Cached so maximize/restore transitions can be pushed to Dart.
  bool is_maximized_ = false;

  // Whether the window was zoomed when it was hidden to the tray, so it comes
  // back in the same state.
  bool hidden_maximized_ = false;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
