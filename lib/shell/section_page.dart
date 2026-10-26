import 'package:flutter/material.dart';

/// Shared layout for the tabs that do not have their real UI yet.
///
/// Each tab keeps its own file under `lib/features/` so the placeholder can be
/// replaced with the real screen without touching the navigation shell.
class SectionPage extends StatelessWidget {
  const SectionPage({
    super.key,
    required this.title,
    required this.summary,
    required this.icon,
    this.planned = const <String>[],
    this.action,
    this.body,
    this.showHeader = true,
    this.plannedLabel = 'Planned for this tab',
  });

  final String title;
  final String summary;
  final IconData icon;

  /// Bullet list of what this tab will contain once it is implemented.
  final List<String> planned;

  /// Optional primary action shown on the right of the title.
  final Widget? action;

  /// Real UI placed between the summary and the [planned] list, for screens
  /// that are being implemented one section at a time.
  final Widget? body;

  /// Set to false when the surrounding route already has a title, e.g. an
  /// `AppBar`.
  final bool showHeader;

  /// Heading above [planned].
  final String plannedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        if (showHeader) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 16),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 28),
        if (body != null) ...[
          body!,
          const SizedBox(height: 28),
        ],
        Text(
          plannedLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in planned)
              Chip(
                label: Text(item),
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
          ],
        ),
      ],
    );
  }
}
