import 'package:flutter/material.dart';

import 'window_chrome.dart';

/// Flutter-drawn replacement for the Windows title bar.
///
/// The native window is created without a frame (see
/// `windows/runner/flutter_window.cpp`), so this widget provides the drag
/// surface together with the minimize / maximize / close buttons.
///
/// Only add it on Windows (`WindowChrome.isSupported`).
class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({
    super.key,
    this.title = 'Vola Fix',
    this.height = 36,
    this.leading,
  });

  final String title;
  final double height;

  /// Optional widget shown before [title], typically the app icon.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withAlpha(28)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (_) => WindowChrome.instance.startDrag(),
              onDoubleTap: WindowChrome.instance.toggleMaximize,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _CaptionButton(
            label: 'Minimize',
            icon: Icons.remove,
            onPressed: WindowChrome.instance.minimize,
          ),
          ListenableBuilder(
            listenable: WindowChrome.instance,
            builder: (context, _) {
              final maximized = WindowChrome.instance.isMaximized;
              return _CaptionButton(
                label: maximized ? 'Restore' : 'Maximize',
                icon: maximized ? Icons.filter_none : Icons.crop_square,
                iconSize: 12,
                onPressed: WindowChrome.instance.toggleMaximize,
              );
            },
          ),
          _CaptionButton(
            label: 'Close',
            icon: Icons.close,
            isCloseButton: true,
            onPressed: WindowChrome.instance.close,
          ),
        ],
      ),
    );
  }
}

class _CaptionButton extends StatefulWidget {
  const _CaptionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconSize = 14,
    this.isCloseButton = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;
  final bool isCloseButton;

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color hoverBackground;
    if (widget.isCloseButton) {
      hoverBackground = const Color(0xFFC42B1C);
    } else {
      hoverBackground =
          isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15);
    }

    final foreground = widget.isCloseButton && _hovered
        ? Colors.white
        : theme.colorScheme.onSurface;

    return Semantics(
      button: true,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 46,
            color: _hovered ? hoverBackground : Colors.transparent,
            alignment: Alignment.center,
            child: Icon(widget.icon, size: widget.iconSize, color: foreground),
          ),
        ),
      ),
    );
  }
}
