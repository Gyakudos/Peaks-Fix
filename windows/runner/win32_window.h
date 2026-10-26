#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// A class abstraction for a high DPI-aware Win32 Window. Intended to be
// inherited from by classes that wish to specialize with custom
// rendering and input handling
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  // Creates a win32 window with |title| that is positioned and sized using
  // |origin| and |size|. New windows are created on the default monitor. Window
  // sizes are specified to the OS in physical pixels, hence to ensure a
  // consistent size this function will scale the inputted width and height as
  // as appropriate for the default monitor. The window is invisible until
  // |Show| is called. Returns true if the window was created successfully.
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  // Creates a window with |title|, restoring the placement stored by the
  // previous session when it still lands on a connected monitor. Otherwise the
  // window is centered on the primary monitor at |default_size| logical pixels,
  // scaled for its DPI. As with the overload above, the window stays invisible
  // until |Show| is called.
  bool Create(const std::wstring& title, const Size& default_size);

  // Returns the top-level window of an already running instance of this
  // application, or nullptr when no such window exists.
  static HWND FindExistingInstance();

  // Show the current window. Returns true if the window was successfully shown.
  bool Show();

  // Release OS resources associated with window.
  void Destroy();

  // Inserts |content| into the window tree.
  void SetChildContent(HWND content);

  // Returns the backing Window handle to enable clients to set icon and other
  // window properties. Returns nullptr if the window has been destroyed.
  HWND GetHandle();

  // If true, closing this window will quit the application.
  void SetQuitOnClose(bool quit_on_close);

  // Return a RECT representing the bounds of the current client area.
  RECT GetClientArea();

 protected:
  // Processes and route salient window messages for mouse handling,
  // size change and DPI. Delegates handling of these to member overloads that
  // inheriting classes can handle.
  virtual LRESULT MessageHandler(HWND window,
                                 UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  // Called when CreateAndShow is called, allowing subclass window-related
  // setup. Subclasses should return false if setup fails.
  virtual bool OnCreate();

  // Called when Destroy is called.
  virtual void OnDestroy();

 private:
  friend class WindowClassRegistrar;

  // Creates the top-level window for the given physical-pixel |bounds|.
  bool CreateInternal(const std::wstring& title,
                      const RECT& bounds,
                      bool maximized);

  // Returns |size| (logical pixels) centered in the work area of the primary
  // monitor.
  static RECT CenteredBounds(const Size& size);

  // Loads the placement persisted by SavePlacement. Returns false when nothing
  // usable has been stored yet.
  static bool LoadPlacement(RECT* bounds, bool* maximized);

  // Persists the current window rect (and maximized state) under HKCU.
  void SavePlacement(HWND window);

  // Returns true when enough of |bounds| is visible on a connected monitor for
  // the user to grab the window.
  static bool IsPlacementVisible(const RECT& bounds);

  // Records the current window rect as the "restored" bounds used by
  // SavePlacement. Ignored while the window is maximized, minimized or hidden.
  void UpdateNormalBounds(HWND window);

  // OS callback called by message pump. Handles the WM_NCCREATE message which
  // is passed when the non-client area is being created and enables automatic
  // non-client DPI scaling so that the non-client area automatically
  // responds to changes in DPI. All other messages are handled by
  // MessageHandler.
  static LRESULT CALLBACK WndProc(HWND const window,
                                  UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  // Retrieves a class instance pointer for |window|
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  // Update the window frame's theme to match the system theme.
  static void UpdateTheme(HWND const window);

  bool quit_on_close_ = false;

  // Whether Show() should maximize instead of showing normally, set when a
  // maximized placement was restored.
  bool show_maximized_ = false;

  // Last known restored (non-maximized) window bounds in physical pixels.
  RECT normal_bounds_ = {};
  bool has_normal_bounds_ = false;

  // window handle for top level window.
  HWND window_handle_ = nullptr;

  // window handle for hosted content.
  HWND child_content_ = nullptr;
};

#endif  // RUNNER_WIN32_WINDOW_H_
