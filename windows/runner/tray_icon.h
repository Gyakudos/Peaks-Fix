#ifndef RUNNER_TRAY_ICON_H_
#define RUNNER_TRAY_ICON_H_

#include <windows.h>
#include <shellapi.h>

#include <string>

// Commands returned by TrayIcon::ShowContextMenu.
constexpr UINT kTrayMenuShow = 1;
constexpr UINT kTrayMenuHide = 2;
constexpr UINT kTrayMenuExit = 3;

// Wraps Shell_NotifyIcon for a single notification-area icon owned by a window.
class TrayIcon {
 public:
  TrayIcon() = default;
  ~TrayIcon();

  TrayIcon(const TrayIcon&) = delete;
  TrayIcon& operator=(const TrayIcon&) = delete;

  // Adds the icon, whose clicks are delivered to |owner| as
  // |callback_message|. Returns false when the shell refused the icon (for
  // example while Explorer is restarting).
  bool Create(HWND owner,
              UINT callback_message,
              HICON icon,
              const std::wstring& tooltip);

  void Remove();

  // Re-adds the icon after Explorer restarts, which discards all icons.
  void Recreate();

  // Shows the tray context menu at |screen_point| and returns the chosen
  // command, or 0 when the menu was dismissed.
  UINT ShowContextMenu(POINT screen_point, bool window_visible);

 private:
  NOTIFYICONDATAW data_ = {};
  bool added_ = false;
};

#endif  // RUNNER_TRAY_ICON_H_
