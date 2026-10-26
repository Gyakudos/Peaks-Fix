#include "flutter_window.h"

#include <flutter/standard_method_codec.h>
#include <flutter_windows.h>
#include <windowsx.h>

#include <optional>
#include <utility>

#include "flutter/generated_plugin_registrant.h"
#include "resource.h"

namespace {

// Set to false to fall back to the native Windows title bar. The Flutter title
// bar (lib/window/window_title_bar.dart) has to be removed from the widget tree
// as well; see WINDOWS_SHELL.md.
constexpr bool kUseCustomFrame = true;

// Hides the window to the notification area instead of the taskbar when it is
// minimized.
constexpr bool kMinimizeToTray = true;

// Set to true to keep the app running in the tray when the window is closed.
// The tray menu's "Exit" always quits.
constexpr bool kCloseToTray = false;

// Width of the invisible resize border in logical pixels.
constexpr int kResizeBorderWidth = 6;

// Smallest size the user can drag the window down to, in logical pixels.
constexpr int kMinimumWidth = 480;
constexpr int kMinimumHeight = 360;

constexpr UINT kTrayCallbackMessage = WM_APP + 1;
constexpr wchar_t kTrayTooltip[] = L"Vola Fix";

// Converts a logical pixel value to physical pixels for |window|'s monitor.
int ScaleForWindow(HWND window, int value) {
  HMONITOR monitor = ::MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST);
  const double scale_factor = FlutterDesktopGetDpiForMonitor(monitor) / 96.0;
  return static_cast<int>(value * scale_factor);
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  CreateMethodChannel();
  SetChildContent(flutter_controller_->view()->GetNativeWindow());
  CreateTrayIcon();
  is_maximized_ = ::IsZoomed(GetHandle()) != FALSE;

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (tray_icon_handle_ != nullptr) {
    tray_icon_.Remove();
    ::DestroyIcon(tray_icon_handle_);
    tray_icon_handle_ = nullptr;
  }

  method_channel_.reset();

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  // Explorer broadcasts this when the taskbar is (re)created.
  if (taskbar_created_message_ != 0 && message == taskbar_created_message_) {
    tray_icon_.Recreate();
    return 0;
  }

  if constexpr (kUseCustomFrame) {
    const std::optional<LRESULT> result =
        HandleCustomFrameMessage(hwnd, message, wparam, lparam);
    if (result.has_value()) {
      return result.value();
    }
  }

  switch (message) {
    case kTrayCallbackMessage:
      HandleTrayMessage(hwnd, lparam);
      return 0;

    case WM_SYSCOMMAND:
      if ((wparam & 0xFFF0) == static_cast<WPARAM>(SC_MINIMIZE)) {
        Minimize();
        return 0;
      }
      break;

    case WM_CLOSE:
      if constexpr (kCloseToTray) {
        HideToTray();
        return 0;
      }
      break;

    case WM_SIZE: {
      const bool maximized = ::IsZoomed(hwnd) != FALSE;
      if (maximized != is_maximized_) {
        is_maximized_ = maximized;
        NotifyMaximizedChanged(maximized);
      }
      break;
    }

    case WM_FONTCHANGE:
      if (flutter_controller_) {
        flutter_controller_->engine()->ReloadSystemFonts();
      }
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

std::optional<LRESULT> FlutterWindow::HandleCustomFrameMessage(
    HWND hwnd, UINT const message, WPARAM const wparam, LPARAM const lparam) {
  switch (message) {
    // Give the whole window rect to Flutter, so the title bar can be drawn in
    // Dart. WS_THICKFRAME/WS_CAPTION stay set so DWM keeps drawing the drop
    // shadow and Windows keeps its snap/maximize animations.
    //
    // A zoomed window is inflated by Windows' invisible frame (8px on every
    // edge here) while its client area is expected to be the work area. Since
    // the native frame is gone, the client rect is pinned to the work area
    // explicitly; otherwise 8px of Flutter content hangs off every edge.
    case WM_NCCALCSIZE: {
      if (::IsZoomed(hwnd)) {
        RECT* client =
            wparam != 0
                ? &reinterpret_cast<NCCALCSIZE_PARAMS*>(lparam)->rgrc[0]
                : reinterpret_cast<RECT*>(lparam);
        const HMONITOR monitor =
            ::MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
        MONITORINFO monitor_info = {sizeof(MONITORINFO)};
        if (::GetMonitorInfo(monitor, &monitor_info)) {
          *client = monitor_info.rcWork;
        }
      }
      // Otherwise the client area is the whole window.
      return 0;
    }

    // Without a native frame there is nothing to grab, so the resize edges are
    // hit-tested by hand.
    case WM_NCHITTEST: {
      if (::IsZoomed(hwnd)) {
        break;
      }

      const POINT cursor = {GET_X_LPARAM(lparam), GET_Y_LPARAM(lparam)};
      RECT window;
      ::GetWindowRect(hwnd, &window);

      const int border = ScaleForWindow(hwnd, kResizeBorderWidth);
      const bool on_left =
          cursor.x >= window.left && cursor.x < window.left + border;
      const bool on_right =
          cursor.x <= window.right && cursor.x > window.right - border;
      const bool on_top =
          cursor.y >= window.top && cursor.y < window.top + border;
      const bool on_bottom =
          cursor.y <= window.bottom && cursor.y > window.bottom - border;

      if (on_top && on_left) {
        return HTTOPLEFT;
      }
      if (on_top && on_right) {
        return HTTOPRIGHT;
      }
      if (on_bottom && on_left) {
        return HTBOTTOMLEFT;
      }
      if (on_bottom && on_right) {
        return HTBOTTOMRIGHT;
      }
      if (on_left) {
        return HTLEFT;
      }
      if (on_right) {
        return HTRIGHT;
      }
      if (on_top) {
        return HTTOP;
      }
      if (on_bottom) {
        return HTBOTTOM;
      }
      break;
    }

    // A frameless maximized window would otherwise cover the taskbar, so
    // maximize to the work area of the current monitor and keep the user from
    // shrinking the window into nothing. Windows still inflates the zoomed
    // window rect by its invisible frame; WM_NCCALCSIZE pins the client area
    // back to the work area.
    case WM_GETMINMAXINFO: {
      auto* info = reinterpret_cast<MINMAXINFO*>(lparam);
      const HMONITOR monitor =
          ::MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
      MONITORINFO monitor_info = {sizeof(MONITORINFO)};
      if (::GetMonitorInfo(monitor, &monitor_info)) {
        info->ptMaxPosition.x =
            monitor_info.rcWork.left - monitor_info.rcMonitor.left;
        info->ptMaxPosition.y =
            monitor_info.rcWork.top - monitor_info.rcMonitor.top;
        info->ptMaxSize.x =
            monitor_info.rcWork.right - monitor_info.rcWork.left;
        info->ptMaxSize.y =
            monitor_info.rcWork.bottom - monitor_info.rcWork.top;
      }

      info->ptMinTrackSize.x = ScaleForWindow(hwnd, kMinimumWidth);
      info->ptMinTrackSize.y = ScaleForWindow(hwnd, kMinimumHeight);
      return 0;
    }

    default:
      break;
  }

  return std::nullopt;
}

void FlutterWindow::CreateMethodChannel() {
  method_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), "vola/window",
          &flutter::StandardMethodCodec::GetInstance());

  method_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) { HandleMethodCall(call, std::move(result)); });
}

void FlutterWindow::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const std::string& method = call.method_name();
  HWND window = GetHandle();

  if (method == "startDrag") {
    // Reply before entering the modal move loop, which does not return until
    // the user releases the mouse.
    result->Success();
    if (window != nullptr) {
      ::ReleaseCapture();
      ::SendMessage(window, WM_NCLBUTTONDOWN, static_cast<WPARAM>(HTCAPTION), 0);
    }
  } else if (method == "minimize") {
    Minimize();
    result->Success();
  } else if (method == "toggleMaximize") {
    ToggleMaximize();
    result->Success();
  } else if (method == "close") {
    if (window != nullptr) {
      ::PostMessage(window, WM_CLOSE, 0, 0);
    }
    result->Success();
  } else if (method == "isMaximized") {
    result->Success(flutter::EncodableValue(::IsZoomed(window) != FALSE));
  } else {
    result->NotImplemented();
  }
}

void FlutterWindow::Minimize() {
  if constexpr (kMinimizeToTray) {
    HideToTray();
  } else {
    HWND window = GetHandle();
    if (window != nullptr) {
      ::ShowWindow(window, SW_MINIMIZE);
    }
  }
}

void FlutterWindow::ToggleMaximize() {
  HWND window = GetHandle();
  if (window == nullptr) {
    return;
  }
  ::ShowWindow(window, ::IsZoomed(window) ? SW_RESTORE : SW_MAXIMIZE);
}

void FlutterWindow::ShowFromTray() {
  HWND window = GetHandle();
  if (window == nullptr) {
    return;
  }
  ::ShowWindow(window, SW_SHOW);
  if (::IsIconic(window)) {
    ::ShowWindow(window, SW_RESTORE);
  }
  if (hidden_maximized_ && ::IsZoomed(window) == FALSE) {
    ::ShowWindow(window, SW_MAXIMIZE);
  }
  hidden_maximized_ = false;
  ::SetForegroundWindow(window);
}

void FlutterWindow::HideToTray() {
  HWND window = GetHandle();
  if (window != nullptr) {
    hidden_maximized_ = ::IsZoomed(window) != FALSE;
    ::ShowWindow(window, SW_HIDE);
  }
}

void FlutterWindow::NotifyMaximizedChanged(bool maximized) {
  if (!method_channel_) {
    return;
  }
  method_channel_->InvokeMethod(
      "maximizedChanged",
      std::make_unique<flutter::EncodableValue>(maximized));
}

void FlutterWindow::CreateTrayIcon() {
  HWND window = GetHandle();
  if (window == nullptr) {
    return;
  }

  taskbar_created_message_ = ::RegisterWindowMessageW(L"TaskbarCreated");

  tray_icon_handle_ = static_cast<HICON>(::LoadImageW(
      ::GetModuleHandle(nullptr), MAKEINTRESOURCEW(IDI_APP_ICON), IMAGE_ICON,
      ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON),
      LR_DEFAULTCOLOR));

  tray_icon_.Create(window, kTrayCallbackMessage, tray_icon_handle_,
                    kTrayTooltip);
}

void FlutterWindow::HandleTrayMessage(HWND window, LPARAM lparam) {
  switch (LOWORD(lparam)) {
    case WM_LBUTTONDBLCLK:
      ShowFromTray();
      return;

    case WM_RBUTTONUP: {
      POINT cursor;
      ::GetCursorPos(&cursor);
      const bool window_visible = ::IsWindowVisible(window) != FALSE;
      switch (tray_icon_.ShowContextMenu(cursor, window_visible)) {
        case kTrayMenuShow:
          ShowFromTray();
          break;
        case kTrayMenuHide:
          HideToTray();
          break;
        case kTrayMenuExit:
          ::DestroyWindow(window);
          break;
        default:
          break;
      }
      return;
    }

    default:
      return;
  }
}
