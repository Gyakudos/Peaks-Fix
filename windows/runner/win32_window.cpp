#include "win32_window.h"

#include <dwmapi.h>
#include <flutter_windows.h>

#include "resource.h"

namespace {

/// Window attribute that enables dark mode window decorations.
///
/// Redefined in case the developer's machine has a Windows SDK older than
/// version 10.0.22000.0.
/// See: https://docs.microsoft.com/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute
#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

/// Registry key for app theme preference.
///
/// A value of 0 indicates apps should use dark mode. A non-zero or missing
/// value indicates apps should use light mode.
constexpr const wchar_t kGetPreferredBrightnessRegKey[] =
  L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize";
constexpr const wchar_t kGetPreferredBrightnessRegValue[] = L"AppsUseLightTheme";

// Registry location of the window placement persisted between sessions.
constexpr const wchar_t kWindowStateKey[] =
    L"Software\\Vola\\Vola Fix\\WindowState";

bool ReadDword(HKEY key, const wchar_t* name, DWORD* value) {
  DWORD size = sizeof(DWORD);
  DWORD type = 0;
  if (::RegQueryValueExW(key, name, nullptr, &type,
                         reinterpret_cast<LPBYTE>(value),
                         &size) != ERROR_SUCCESS) {
    return false;
  }
  return type == static_cast<DWORD>(REG_DWORD) && size == sizeof(DWORD);
}

bool WriteDword(HKEY key, const wchar_t* name, DWORD value) {
  return ::RegSetValueExW(key, name, 0, REG_DWORD,
                          reinterpret_cast<const BYTE*>(&value),
                          sizeof(value)) == ERROR_SUCCESS;
}

// The number of Win32Window objects that currently exist.
static int g_active_window_count = 0;

using EnableNonClientDpiScaling = BOOL __stdcall(HWND hwnd);

// Scale helper to convert logical scaler values to physical using passed in
// scale factor
int Scale(int source, double scale_factor) {
  return static_cast<int>(source * scale_factor);
}

// Dynamically loads the |EnableNonClientDpiScaling| from the User32 module.
// This API is only needed for PerMonitor V1 awareness mode.
void EnableFullDpiSupportIfAvailable(HWND hwnd) {
  HMODULE user32_module = LoadLibraryA("User32.dll");
  if (!user32_module) {
    return;
  }
  auto enable_non_client_dpi_scaling =
      reinterpret_cast<EnableNonClientDpiScaling*>(
          GetProcAddress(user32_module, "EnableNonClientDpiScaling"));
  if (enable_non_client_dpi_scaling != nullptr) {
    enable_non_client_dpi_scaling(hwnd);
  }
  FreeLibrary(user32_module);
}

}  // namespace

// Manages the Win32Window's window class registration.
class WindowClassRegistrar {
 public:
  ~WindowClassRegistrar() = default;

  // Returns the singleton registrar instance.
  static WindowClassRegistrar* GetInstance() {
    if (!instance_) {
      instance_ = new WindowClassRegistrar();
    }
    return instance_;
  }

  // Returns the name of the window class, registering the class if it hasn't
  // previously been registered.
  const wchar_t* GetWindowClass();

  // Unregisters the window class. Should only be called if there are no
  // instances of the window.
  void UnregisterWindowClass();

 private:
  WindowClassRegistrar() = default;

  static WindowClassRegistrar* instance_;

  bool class_registered_ = false;
};

WindowClassRegistrar* WindowClassRegistrar::instance_ = nullptr;

const wchar_t* WindowClassRegistrar::GetWindowClass() {
  if (!class_registered_) {
    WNDCLASS window_class{};
    window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
    window_class.lpszClassName = kWindowClassName;
    window_class.style = CS_HREDRAW | CS_VREDRAW;
    window_class.cbClsExtra = 0;
    window_class.cbWndExtra = 0;
    window_class.hInstance = GetModuleHandle(nullptr);
    window_class.hIcon =
        LoadIcon(window_class.hInstance, MAKEINTRESOURCE(IDI_APP_ICON));
    window_class.hbrBackground = 0;
    window_class.lpszMenuName = nullptr;
    window_class.lpfnWndProc = Win32Window::WndProc;
    RegisterClass(&window_class);
    class_registered_ = true;
  }
  return kWindowClassName;
}

void WindowClassRegistrar::UnregisterWindowClass() {
  UnregisterClass(kWindowClassName, nullptr);
  class_registered_ = false;
}

Win32Window::Win32Window() {
  ++g_active_window_count;
}

Win32Window::~Win32Window() {
  --g_active_window_count;
  Destroy();
}

bool Win32Window::Create(const std::wstring& title,
                         const Size& default_size) {
  RECT bounds = CenteredBounds(default_size);
  RECT saved_bounds;
  bool maximized = false;
  if (LoadPlacement(&saved_bounds, &maximized) &&
      IsPlacementVisible(saved_bounds)) {
    bounds = saved_bounds;
  }

  return CreateInternal(title, bounds, maximized);
}

bool Win32Window::Create(const std::wstring& title,
                         const Point& origin,
                         const Size& size) {
  const POINT target_point = {static_cast<LONG>(origin.x),
                              static_cast<LONG>(origin.y)};
  HMONITOR monitor = MonitorFromPoint(target_point, MONITOR_DEFAULTTONEAREST);
  UINT dpi = FlutterDesktopGetDpiForMonitor(monitor);
  double scale_factor = dpi / 96.0;

  RECT bounds = {};
  bounds.left = Scale(static_cast<int>(origin.x), scale_factor);
  bounds.top = Scale(static_cast<int>(origin.y), scale_factor);
  bounds.right = bounds.left + Scale(static_cast<int>(size.width), scale_factor);
  bounds.bottom =
      bounds.top + Scale(static_cast<int>(size.height), scale_factor);

  return CreateInternal(title, bounds, false);
}

bool Win32Window::CreateInternal(const std::wstring& title,
                                 const RECT& bounds,
                                 bool maximized) {
  Destroy();

  const wchar_t* window_class =
      WindowClassRegistrar::GetInstance()->GetWindowClass();

  HWND window = CreateWindow(
      window_class, title.c_str(), WS_OVERLAPPEDWINDOW, bounds.left, bounds.top,
      static_cast<int>(bounds.right - bounds.left),
      static_cast<int>(bounds.bottom - bounds.top), nullptr, nullptr,
      GetModuleHandle(nullptr), this);

  if (!window) {
    return false;
  }

  show_maximized_ = maximized;
  normal_bounds_ = bounds;
  has_normal_bounds_ = true;
  UpdateTheme(window);

  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, show_maximized_ ? SW_SHOWMAXIMIZED
                                                    : SW_SHOWNORMAL);
}

// static
LRESULT CALLBACK Win32Window::WndProc(HWND const window,
                                      UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));

    auto that = static_cast<Win32Window*>(window_struct->lpCreateParams);
    EnableFullDpiSupportIfAvailable(window);
    that->window_handle_ = window;
  } else if (Win32Window* that = GetThisFromHandle(window)) {
    return that->MessageHandler(window, message, wparam, lparam);
  }

  return DefWindowProc(window, message, wparam, lparam);
}

LRESULT
Win32Window::MessageHandler(HWND hwnd,
                            UINT const message,
                            WPARAM const wparam,
                            LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      SavePlacement(hwnd);
      window_handle_ = nullptr;
      Destroy();
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;

    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT*>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;

      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top, newWidth,
                   newHeight, SWP_NOZORDER | SWP_NOACTIVATE);

      return 0;
    }
    case WM_SIZE: {
      UpdateNormalBounds(hwnd);
      RECT rect = GetClientArea();
      if (child_content_ != nullptr) {
        // Size and position the child window.
        MoveWindow(child_content_, rect.left, rect.top, rect.right - rect.left,
                   rect.bottom - rect.top, TRUE);
      }
      return 0;
    }

    case WM_MOVE:
      UpdateNormalBounds(hwnd);
      break;

    case WM_ACTIVATE:
      if (child_content_ != nullptr) {
        SetFocus(child_content_);
      }
      return 0;

    case WM_DWMCOLORIZATIONCOLORCHANGED:
      UpdateTheme(hwnd);
      return 0;
  }

  return DefWindowProc(window_handle_, message, wparam, lparam);
}

void Win32Window::Destroy() {
  OnDestroy();

  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  if (g_active_window_count == 0) {
    WindowClassRegistrar::GetInstance()->UnregisterWindowClass();
  }
}

Win32Window* Win32Window::GetThisFromHandle(HWND const window) noexcept {
  return reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT frame = GetClientArea();

  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
             frame.bottom - frame.top, true);

  SetFocus(child_content_);
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

HWND Win32Window::GetHandle() {
  return window_handle_;
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

bool Win32Window::OnCreate() {
  // No-op; provided for subclasses.
  return true;
}

void Win32Window::OnDestroy() {
  // No-op; provided for subclasses.
}

void Win32Window::UpdateTheme(HWND const window) {
  DWORD light_mode;
  DWORD light_mode_size = sizeof(light_mode);
  LSTATUS result = RegGetValue(HKEY_CURRENT_USER, kGetPreferredBrightnessRegKey,
                               kGetPreferredBrightnessRegValue,
                               RRF_RT_REG_DWORD, nullptr, &light_mode,
                               &light_mode_size);

  if (result == ERROR_SUCCESS) {
    BOOL enable_dark_mode = light_mode == 0;
    DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE,
                          &enable_dark_mode, sizeof(enable_dark_mode));
  }
}

HWND Win32Window::FindExistingInstance() {
  return ::FindWindowW(kWindowClassName, nullptr);
}

RECT Win32Window::CenteredBounds(const Size& size) {
  const POINT anchor = {0, 0};
  HMONITOR monitor = MonitorFromPoint(anchor, MONITOR_DEFAULTTOPRIMARY);
  MONITORINFO monitor_info = {sizeof(MONITORINFO)};
  if (!GetMonitorInfo(monitor, &monitor_info)) {
    return RECT{0, 0, static_cast<LONG>(size.width),
                static_cast<LONG>(size.height)};
  }

  const double scale_factor = FlutterDesktopGetDpiForMonitor(monitor) / 96.0;
  const int width = Scale(static_cast<int>(size.width), scale_factor);
  const int height = Scale(static_cast<int>(size.height), scale_factor);
  const int work_width = monitor_info.rcWork.right - monitor_info.rcWork.left;
  const int work_height = monitor_info.rcWork.bottom - monitor_info.rcWork.top;

  RECT bounds = {};
  bounds.left = monitor_info.rcWork.left + (work_width - width) / 2;
  bounds.top = monitor_info.rcWork.top + (work_height - height) / 2;
  bounds.right = bounds.left + width;
  bounds.bottom = bounds.top + height;
  return bounds;
}

bool Win32Window::LoadPlacement(RECT* bounds, bool* maximized) {
  HKEY key = nullptr;
  if (::RegOpenKeyExW(HKEY_CURRENT_USER, kWindowStateKey, 0, KEY_QUERY_VALUE,
                      &key) != ERROR_SUCCESS) {
    return false;
  }

  DWORD left = 0;
  DWORD top = 0;
  DWORD width = 0;
  DWORD height = 0;
  DWORD maximized_value = 0;
  const bool complete = ReadDword(key, L"Left", &left) &&
                        ReadDword(key, L"Top", &top) &&
                        ReadDword(key, L"Width", &width) &&
                        ReadDword(key, L"Height", &height);
  ReadDword(key, L"Maximized", &maximized_value);
  ::RegCloseKey(key);

  if (!complete || width < 120u || height < 120u) {
    return false;
  }

  bounds->left = static_cast<LONG>(left);
  bounds->top = static_cast<LONG>(top);
  bounds->right = bounds->left + static_cast<LONG>(width);
  bounds->bottom = bounds->top + static_cast<LONG>(height);
  *maximized = maximized_value != 0;
  return true;
}

void Win32Window::SavePlacement(HWND window) {
  if (!has_normal_bounds_) {
    return;
  }

  const int width = static_cast<int>(normal_bounds_.right - normal_bounds_.left);
  const int height =
      static_cast<int>(normal_bounds_.bottom - normal_bounds_.top);
  if (width < 120 || height < 120) {
    return;
  }

  HKEY key = nullptr;
  if (::RegCreateKeyExW(HKEY_CURRENT_USER, kWindowStateKey, 0, nullptr, 0,
                        KEY_SET_VALUE, nullptr, &key,
                        nullptr) != ERROR_SUCCESS) {
    return;
  }

  const bool maximized = ::IsZoomed(window) != FALSE;
  WriteDword(key, L"Left", static_cast<DWORD>(normal_bounds_.left));
  WriteDword(key, L"Top", static_cast<DWORD>(normal_bounds_.top));
  WriteDword(key, L"Width", static_cast<DWORD>(width));
  WriteDword(key, L"Height", static_cast<DWORD>(height));
  WriteDword(key, L"Maximized", maximized ? 1 : 0);
  ::RegCloseKey(key);
}

bool Win32Window::IsPlacementVisible(const RECT& bounds) {
  HMONITOR monitor = ::MonitorFromRect(&bounds, MONITOR_DEFAULTTONULL);
  if (monitor == nullptr) {
    return false;
  }

  MONITORINFO monitor_info = {sizeof(MONITORINFO)};
  if (!::GetMonitorInfo(monitor, &monitor_info)) {
    return true;
  }

  RECT visible = {};
  if (!::IntersectRect(&visible, &bounds, &monitor_info.rcWork)) {
    return false;
  }

  return (visible.right - visible.left) >= 160 &&
         (visible.bottom - visible.top) >= 60;
}

void Win32Window::UpdateNormalBounds(HWND window) {
  if (::IsZoomed(window) || ::IsIconic(window) || !::IsWindowVisible(window)) {
    return;
  }

  RECT bounds;
  if (!::GetWindowRect(window, &bounds)) {
    return;
  }

  const int width = static_cast<int>(bounds.right - bounds.left);
  const int height = static_cast<int>(bounds.bottom - bounds.top);
  if (width < 120 || height < 120) {
    return;
  }

  normal_bounds_ = bounds;
  has_normal_bounds_ = true;
}