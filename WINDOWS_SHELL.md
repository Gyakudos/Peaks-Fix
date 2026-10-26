# Windows shell

The Windows runner has been extended from the stock Flutter template into a
small native shell:

| Feature | Where |
| --- | --- |
| Window geometry persistence (position, size, maximized) | `windows/runner/win32_window.cpp` |
| Centering on the primary monitor on first launch | `windows/runner/win32_window.cpp` |
| Frameless window + Flutter-drawn title bar | `windows/runner/flutter_window.cpp`, `lib/window/window_title_bar.dart` |
| Notification-area (tray) icon | `windows/runner/tray_icon.{h,cpp}` |
| Single instance | `windows/runner/main.cpp` |

New files: `windows/runner/tray_icon.h`, `windows/runner/tray_icon.cpp`,
`lib/window/window_chrome.dart`, `lib/window/window_title_bar.dart`,
`WINDOWS_SHELL.md`. `windows/runner/CMakeLists.txt` gained `tray_icon.cpp` and
`shell32.lib`.

## Behavior

**Startup placement.** The window opens at the position/size it had when it was
last closed. If nothing has been saved yet — or the saved rect no longer
overlaps a connected monitor (unplugged display) — it opens 1280x720 centered in
the work area of the primary monitor, scaled for that monitor's DPI.

The placement is stored per Windows user under

```
HKEY_CURRENT_USER\Software\Vola\Vola Fix\WindowState
    Left, Top, Width, Height : DWORD (physical pixels)
    Maximized                : DWORD (0/1)
```

Reset it with:

```powershell
reg delete "HKCU\Software\Vola\Vola Fix\WindowState" /f
```

**Title bar.** The native frame is removed (`WM_NCCALCSIZE`), the resize border
is hit-tested manually (`WM_NCHITTEST`), and the visible title bar is a Flutter
widget. Drag it to move the window, double-click it to maximize/restore, and use
the buttons on the right for minimize / maximize / close.

When maximized, Windows still inflates the window rect by its invisible frame
(8px per edge), so the window rect reads `-8,-8 3456x1456` on a 3440x1440
display. `WM_NCCALCSIZE` pins the *client* area back to the monitor work area, so
the Flutter view is exactly `0,0 3440x1440` and nothing is cropped. This is the
same geometry a normal framed window uses when zoomed.

**Minimize goes to the tray.** `WM_SYSCOMMAND`/`SC_MINIMIZE` is intercepted and
the window is hidden, leaving only the tray icon. Double-click the tray icon to
bring it back; right-click for *Show window / Hide window / Exit*. Closing with
the X still quits, because `kCloseToTray` is `false`. If the window was maximized
when it went to the tray, it comes back maximized.

**Single instance.** A second launch (including a shortcut double-click while
the app is in the tray) activates the existing window instead of starting a new
process. Uniqueness is a named mutex, `Local\VolaFix.SingleInstance` — `Local\`
keeps separate Windows sessions (RDP) independent.

## Method channel

Native side: `vola/window` in `flutter_window.cpp`. Dart side:
`WindowChrome` in `lib/window/window_chrome.dart`.

Dart → native:

| Method | Effect |
| --- | --- |
| `startDrag` | Enters the native move loop (title-bar drag) |
| `minimize` | Minimizes to the tray, or to the taskbar if `kMinimizeToTray` is false |
| `toggleMaximize` | Maximize ⟷ restore |
| `close` | Posts `WM_CLOSE` (quits, or hides when `kCloseToTray` is true) |
| `isMaximized` | Returns the current maximized state |

Native → Dart:

| Method | Arguments |
| --- | --- |
| `maximizedChanged` | `bool` — pushed on every maximize/restore, so the title bar can swap its icon |

`WindowChrome` is a no-op on non-Windows platforms, so `HomeScreen` can include
the title bar conditionally:

```dart
if (WindowChrome.isSupported) const WindowTitleBar(),
```

## Tuning constants

`windows/runner/flutter_window.cpp`:

| Constant | Default | Meaning |
| --- | --- | --- |
| `kUseCustomFrame` | `true` | `false` restores the native title bar — remove `WindowTitleBar` from the widget tree at the same time |
| `kMinimizeToTray` | `true` | Minimize hides the window to the tray |
| `kCloseToTray` | `false` | Close hides to the tray instead of quitting |
| `kResizeBorderWidth` | `6` | Invisible resize edge, logical pixels |
| `kMinimumWidth` / `kMinimumHeight` | `480` / `360` | Smallest size the user can resize to, logical pixels |

## Known limitations

- The Windows 11 snap-layout flyout (hovering the maximize button) does not
  appear, because the button is drawn by Flutter and not reported as
  `HTMAXBUTTON`. Dragging to a screen edge and `Win`+arrow still snap.
- No native system-menu icon (top-left). `Alt`+`Space` still opens the menu.
- Windows 11 may not round the corners of the frameless window.
- The tray icon needs Explorer; if the shell restarts, the icon is re-added on
  the `TaskbarCreated` broadcast.
- `SetForegroundWindow` from the second instance can be refused by Windows if
  the user launched it from an unrelated foreground app; the window is still
  shown.

## Testing checklist

Verified on this machine with Flutter 3.47.8 / MSVC 14.44 / Windows 11 25H2
(3440x1440, 100% scaling, work area == full screen):

| Check | Result |
| --- | --- |
| First launch, no saved placement | Opens `1080,360 1280x720`, client == window (frameless) |
| Move + resize + close | `Left=400 Top=250 Width=1200 Height=800 Maximized=0` written to the registry |
| Relaunch | Restores `400,250 1200x800` exactly |
| Maximize | Client/Flutter view `0,0 3440x1440`; nothing off-screen |
| Maximize + close | Normal bounds kept, `Maximized=1`; relaunch comes back zoomed |
| Restore from maximize | Returns to the saved normal bounds, client == window |
| Minimize (`SC_MINIMIZE`) | Window hidden, process alive, tray icon present |
| Tray double-click | Window shown again, still maximized |
| Second launch | Exits with code 0, first process and window unchanged |
| `flutter analyze` / `flutter test` | Clean / passing |

Still worth checking by hand:

1. Drag the custom title bar (move), drag edges/corners (resize), double-click
   the bar (maximize), and the channel-backed minimize/maximize/close buttons.
2. Unplug/disable the monitor the window was on, then relaunch — it should fall
   back to centered on the primary monitor.
3. Right-click the tray icon → *Hide window* / *Show window* / *Exit*.
4. Snap layouts (`Win`+arrow), and dragging the window to a screen edge.
