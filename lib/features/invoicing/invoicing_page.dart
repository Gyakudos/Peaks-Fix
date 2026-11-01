import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/till.dart';
import '../checkout/checkout_page.dart';
import '../tickets/tickets_page.dart';
import 'till_dialogs.dart';

/// Checkout and closed tickets in one place, plus Open Day / Close Day.
class InvoicingPage extends StatefulWidget {
  const InvoicingPage({super.key});

  @override
  State<InvoicingPage> createState() => _InvoicingPageState();
}

class _InvoicingPageState extends State<InvoicingPage> {
  TillEvent? _last;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final log = await loadTillLog(AppDatabase.instance);
      if (mounted) setState(() => _last = log.isEmpty ? null : log.first);
    } catch (_) {}
  }

  Future<void> _run(Future<bool> Function(BuildContext) action) async {
    await action(context);
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final closed = _last?.type == TillEventType.close;
    final open = _last?.type == TillEventType.open;
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: TabBar(
                  tabs: [
                    Tab(text: 'Checkout'),
                    Tab(text: 'Closed Tickets'),
                  ],
                ),
              ),
              if (_last != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    closed ? 'Day closed' : 'Day open',
                    key: const Key('till-status'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: closed
                          ? theme.colorScheme.outline
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              OutlinedButton.icon(
                key: const Key('open-day'),
                onPressed: open ? null : () => _run(showOpenDayDialog),
                icon: const Icon(Icons.lock_open),
                label: const Text('Open Day'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                key: const Key('close-day'),
                onPressed: closed ? null : () => _run(showCloseDayDialog),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Close Day'),
              ),
              const SizedBox(width: 16),
            ],
          ),
          const Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                CheckoutPage(),
                TicketsPage(closedOnly: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
