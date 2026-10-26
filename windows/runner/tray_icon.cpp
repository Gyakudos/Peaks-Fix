#include "tray_icon.h"

#include <cstddef>

namespace {

constexpr UINT kTrayIconId = 1;

}  // namespace

TrayIcon::~TrayIcon() {
  Remove();
}

bool TrayIcon::Create(HWND owner,
                      UINT callback_message,
                      HICON icon,
                      const std::wstring& tooltip) {
  if (owner == nullptr) {
    return false;
  }

  data_ = {};
  data_.cbSize = sizeof(NOTIFYICONDATAW);
  data_.hWnd = owner;
  data_.uID = kTrayIconId;
  data_.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  data_.uCallbackMessage = callback_message;
  data_.hIcon = icon;

  const std::size_t tip_capacity =
      sizeof(data_.szTip) / sizeof(data_.szTip[0]) - 1;
  const std::size_t tip_length = tooltip.copy(data_.szTip, tip_capacity);
  data_.szTip[tip_length] = L'\0';

  added_ = ::Shell_NotifyIconW(NIM_ADD, &data_) != FALSE;
  return added_;
}

void TrayIcon::Remove() {
  if (!added_) {
    return;
  }
  ::Shell_NotifyIconW(NIM_DELETE, &data_);
  added_ = false;
}

void TrayIcon::Recreate() {
  if (data_.hWnd == nullptr) {
    return;
  }
  if (::Shell_NotifyIconW(NIM_ADD, &data_) != FALSE) {
    added_ = true;
  }
}

UINT TrayIcon::ShowContextMenu(POINT screen_point, bool window_visible) {
  HMENU menu = ::CreatePopupMenu();
  if (menu == nullptr) {
    return 0;
  }

  UINT show_flags = MF_STRING;
  UINT hide_flags = MF_STRING;
  if (window_visible) {
    show_flags |= static_cast<UINT>(MF_GRAYED);
  } else {
    hide_flags |= static_cast<UINT>(MF_GRAYED);
  }
  ::AppendMenuW(menu, show_flags, kTrayMenuShow, L"Show window");
  ::AppendMenuW(menu, hide_flags, kTrayMenuHide, L"Hide window");
  ::AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
  ::AppendMenuW(menu, MF_STRING, kTrayMenuExit, L"Exit");

  // Required for the menu to close when focus moves elsewhere.
  ::SetForegroundWindow(data_.hWnd);

  const UINT command = static_cast<UINT>(::TrackPopupMenu(
      menu, TPM_RETURNCMD | TPM_RIGHTBUTTON | TPM_NONOTIFY, screen_point.x,
      screen_point.y, 0, data_.hWnd, nullptr));

  ::PostMessageW(data_.hWnd, WM_NULL, 0, 0);
  ::DestroyMenu(menu);
  return command;
}
