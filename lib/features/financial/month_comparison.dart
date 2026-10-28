import 'package:flutter/material.dart';

import '../../data/financials.dart';

/// Closed-ticket and staff totals for one calendar month.
class MonthTotals {
  const MonthTotals({
    required this.month,
    required this.ticketCount,
    required this.revenueCents,
    required this.costCents,
    required this.staffPayCents,
    required this.tracked,
  });

  /// First day of the month.
  final DateTime month;
  final int ticketCount;
  final int revenueCents;
  final int costCents;
  final int staffPayCents;
  final Duration tracked;

  int get grossProfitCents => revenueCents - costCents;
  int get netCents => grossProfitCents - staffPayCents;
}

/// Totals for the [months] calendar months ending with the one holding [now],
/// oldest first.
List<MonthTotals> buildMonthlyTotals({
  required List<FinancialTicket> tickets,
  required List<FinancialStaff> staff,
  required DateTime now,
  int months = 12,
}) {
  return [
    for (var i = months - 1; i >= 0; i--)
      () {
        final start = DateTime(now.year, now.month - i);
        final end = DateTime(start.year, start.month + 1);
        final inMonth = tickets.where(
          (ticket) =>
              !ticket.closedAt.isBefore(start) && ticket.closedAt.isBefore(end),
        );
        var tracked = Duration.zero;
        var pay = 0;
        for (final member in staff) {
          final worked = member.trackedIn(start, end);
          tracked += worked;
          pay += member.payCentsFor(worked) ?? 0;
        }
        return MonthTotals(
          month: start,
          ticketCount: inMonth.length,
          revenueCents: inMonth.fold(0, (sum, t) => sum + t.revenueCents),
          costCents: inMonth.fold(0, (sum, t) => sum + t.costCents),
          staffPayCents: pay,
          tracked: tracked,
        );
      }(),
  ];
}

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String monthLabel(DateTime month) =>
    '${_monthNames[month.month - 1]} ${month.year}';

String _money(int cents) {
  final sign = cents < 0 ? '-' : '';
  return '$sign\$${(cents.abs() / 100).toStringAsFixed(2)}';
}

String _hours(Duration duration) =>
    '${(duration.inMinutes / 60).toStringAsFixed(1)}h';

/// Month-to-month table with a side-by-side comparison of any two months.
class MonthComparisonDialog extends StatefulWidget {
  const MonthComparisonDialog({
    super.key,
    required this.tickets,
    required this.staff,
    DateTime? now,
  }) : _now = now;

  final List<FinancialTicket> tickets;
  final List<FinancialStaff> staff;
  final DateTime? _now;

  @override
  State<MonthComparisonDialog> createState() => _MonthComparisonDialogState();
}

class _MonthComparisonDialogState extends State<MonthComparisonDialog> {
  late final List<MonthTotals> _months = buildMonthlyTotals(
    tickets: widget.tickets,
    staff: widget.staff,
    now: widget._now ?? DateTime.now(),
  );
  late int _a = _months.length - 1;
  late int _b = _months.length > 1 ? _months.length - 2 : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Month to month',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    _comparison(context),
                    const SizedBox(height: 20),
                    Text('Last 12 months', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        key: const Key('month-table'),
                        columns: const [
                          DataColumn(label: Text('Month')),
                          DataColumn(label: Text('Tickets'), numeric: true),
                          DataColumn(label: Text('Revenue'), numeric: true),
                          DataColumn(
                              label: Text('Gross profit'), numeric: true),
                          DataColumn(label: Text('Staff pay'), numeric: true),
                          DataColumn(label: Text('Net'), numeric: true),
                        ],
                        rows: [
                          for (final m in _months.reversed)
                            DataRow(cells: [
                              DataCell(Text(monthLabel(m.month))),
                              DataCell(Text('${m.ticketCount}')),
                              DataCell(Text(_money(m.revenueCents))),
                              DataCell(Text(_money(m.grossProfitCents))),
                              DataCell(Text(_money(m.staffPayCents))),
                              DataCell(Text(
                                _money(m.netCents),
                                style: TextStyle(
                                  color: m.netCents < 0
                                      ? theme.colorScheme.error
                                      : const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                            ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _picker(
      String label, int value, ValueChanged<int> onChanged, Key key) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<int>(
        key: key,
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, isDense: true),
        items: [
          for (var i = _months.length - 1; i >= 0; i--)
            DropdownMenuItem(
                value: i, child: Text(monthLabel(_months[i].month))),
        ],
        onChanged: (v) {
          if (v != null) setState(() => onChanged(v));
        },
      ),
    );
  }

  Widget _comparison(BuildContext context) {
    final a = _months[_a];
    final b = _months[_b];
    final theme = Theme.of(context);
    final rows = <(String, int, int, bool)>[
      ('Closed tickets', a.ticketCount, b.ticketCount, false),
      ('Revenue', a.revenueCents, b.revenueCents, true),
      ('Cost', a.costCents, b.costCents, true),
      ('Gross profit', a.grossProfitCents, b.grossProfitCents, true),
      ('Staff pay', a.staffPayCents, b.staffPayCents, true),
      ('Net estimate', a.netCents, b.netCents, true),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compare', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _picker(
                    'Month', _a, (v) => _a = v, const Key('compare-month-a')),
                _picker(
                    'Versus', _b, (v) => _b = v, const Key('compare-month-b')),
              ],
            ),
            const SizedBox(height: 12),
            Table(
              key: const Key('compare-table'),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(3),
              },
              children: [
                TableRow(children: [
                  const SizedBox.shrink(),
                  _cell(monthLabel(a.month), bold: true),
                  _cell(monthLabel(b.month), bold: true),
                  _cell('Change', bold: true),
                ]),
                for (final (label, x, y, isMoney) in rows)
                  TableRow(children: [
                    _cell(label),
                    _cell(isMoney ? _money(x) : '$x'),
                    _cell(isMoney ? _money(y) : '$y'),
                    _change(theme, x, y, isMoney,
                        lowerIsBetter: label == 'Cost' || label == 'Staff pay'),
                  ]),
                TableRow(children: [
                  _cell('Hours tracked'),
                  _cell(_hours(a.tracked)),
                  _cell(_hours(b.tracked)),
                  _cell(''),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          text,
          style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
      );

  Widget _change(ThemeData theme, int current, int previous, bool isMoney,
      {required bool lowerIsBetter}) {
    final diff = current - previous;
    if (diff == 0) return _cell('No change');
    final pct = previous == 0
        ? ''
        : ' (${diff > 0 ? '+' : ''}${(diff * 100 / previous.abs()).round()}%)';
    final good = lowerIsBetter ? diff < 0 : diff > 0;
    final amount = isMoney ? _money(diff.abs()) : '${diff.abs()}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        '${diff > 0 ? '▲' : '▼'} $amount$pct',
        style: TextStyle(
          color: good ? const Color(0xFF2E7D32) : theme.colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
