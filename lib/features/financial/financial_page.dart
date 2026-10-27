import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/financials.dart';
import '../../data/taxes.dart';
import '../settings/settings_page.dart';
import '../tickets/ticket_detail_page.dart';
import '../tickets/ticket_widgets.dart';

/// Money and tracked time for the shop.
///
/// Revenue and cost come from closed tickets; hours and pay come from the staff
/// roster and time clock. Everything is calculated locally from data the shop
/// already records.
class FinancialPage extends StatefulWidget {
  const FinancialPage({super.key, this.database});

  /// Supplied by tests; the app uses the shared database.
  final AppDatabase? database;

  @override
  State<FinancialPage> createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  static const double _maxContentWidth = 980;

  late final AppDatabase _database = widget.database ?? AppDatabase.instance;
  late final Stream<List<FinancialTicket>> _ticketStream =
      _database.watchFinancialTickets();
  late final Stream<List<FinancialStaff>> _staffStream =
      _database.watchFinancialStaff();
  late final Stream<TaxConfig> _taxStream = _database.watchTaxConfig();

  FinancialPeriod _period = FinancialPeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FinancialTicket>>(
      stream: _ticketStream,
      builder: (context, ticketSnapshot) {
        return StreamBuilder<List<FinancialStaff>>(
          stream: _staffStream,
          builder: (context, staffSnapshot) {
            return StreamBuilder<TaxConfig>(
              stream: _taxStream,
              builder: (context, taxSnapshot) {
                final taxes = taxSnapshot.data ?? const TaxConfig();
                final hasError =
                    ticketSnapshot.hasError || staffSnapshot.hasError;
                final loading =
                    !ticketSnapshot.hasData || !staffSnapshot.hasData;
                final now = DateTime.now();
                final allTickets =
                    ticketSnapshot.data ?? const <FinancialTicket>[];
                final tickets = allTickets
                    .where((ticket) => _period.contains(ticket.closedAt, now))
                    .toList();
                final staff = staffSnapshot.data ?? const <FinancialStaff>[];
                final staffRows =
                    _staffRows(staff, _period.startFrom(now), now);

                final revenue = tickets.fold<int>(
                    0, (sum, ticket) => sum + ticket.revenueCents);
                final cost = tickets.fold<int>(
                    0, (sum, ticket) => sum + ticket.costCents);
                final grossProfit = revenue - cost;
                final tracked = staffRows.fold<Duration>(
                  Duration.zero,
                  (sum, row) => sum + row.hours,
                );
                final staffPay = staffRows.fold<int>(
                  0,
                  (sum, row) => sum + (row.payCents ?? 0),
                );
                final netEstimate = grossProfit - staffPay;
                final gstTotal = tickets.fold<int>(
                    0, (sum, ticket) => sum + ticket.gstCents);
                final pstTotal = tickets.fold<int>(
                    0, (sum, ticket) => sum + ticket.pstCents);
                final showGst = taxes.gstEnabled || gstTotal > 0;
                final showPst = taxes.pstEnabled || pstTotal > 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      period: _period,
                      ticketCount: tickets.length,
                      staffCount: staffRows.length,
                      netEstimateCents: netEstimate,
                      gstCents: showGst ? gstTotal : null,
                      pstCents: showPst ? pstTotal : null,
                      onPeriodChanged: (period) =>
                          setState(() => _period = period),
                    ),
                    Expanded(
                      child: switch ((hasError, loading)) {
                        (true, _) => const _Message(
                            icon: Icons.storage_outlined,
                            title: 'Financials could not be loaded',
                            body:
                                'The local database is unavailable. Restart the app '
                                'and try again.',
                          ),
                        (_, true) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        _ => Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _maxContentWidth,
                              ),
                              child: ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 4, 24, 32),
                                children: [
                                  _SummaryCards(
                                    revenueCents: revenue,
                                    costCents: cost,
                                    grossProfitCents: grossProfit,
                                    staffPayCents: staffPay,
                                    netEstimateCents: netEstimate,
                                    tracked: tracked,
                                    ticketCount: tickets.length,
                                    gstCents: showGst ? gstTotal : null,
                                    pstCents: showPst ? pstTotal : null,
                                    gstRateBp: taxes.gstEnabled
                                        ? taxes.gstRateBp
                                        : null,
                                    pstRateBp: taxes.pstEnabled
                                        ? taxes.pstRateBp
                                        : null,
                                  ),
                                  const Divider(height: 36),
                                  const _SectionHeading(
                                      title: 'Hours by staff'),
                                  if (staffRows.isEmpty)
                                    const _EmptyNote(
                                      'Add staff in Settings to track hours and pay.',
                                    )
                                  else ...[
                                    for (final row in staffRows)
                                      _StaffRowCard(
                                        row: row,
                                        period: _period,
                                        database: _database,
                                      ),
                                    const SizedBox(height: 4),
                                    _TotalRow(
                                      label: 'Total tracked time',
                                      value: _formatDuration(tracked),
                                      secondary: _money(staffPay),
                                    ),
                                  ],
                                  const Divider(height: 36),
                                  const _SectionHeading(
                                    title: 'Closed tickets',
                                  ),
                                  if (tickets.isEmpty)
                                    _EmptyNote(
                                      _period == FinancialPeriod.allTime
                                          ? 'Close a paid ticket in Checkout and it '
                                              'will appear here.'
                                          : 'No tickets were closed in this period.',
                                    )
                                  else ...[
                                    for (final ticket in tickets)
                                      _ClosedTicketCard(ticket: ticket),
                                    const SizedBox(height: 4),
                                    _TotalRow(
                                      label: '${tickets.length} closed '
                                          'ticket${tickets.length == 1 ? '' : 's'}',
                                      value: _money(grossProfit),
                                      secondary: 'gross profit',
                                      valueColor: _profitColor(
                                        context,
                                        grossProfit,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  Text(
                                    'Revenue is the invoice total after discounts '
                                    'and before tax. Cost is the recorded part and '
                                    'merchandise cost. GST/PST are shown separately '
                                    'from closed-ticket snapshots. Staff pay uses '
                                    'tracked shifts × hourly rate, so net profit is '
                                    'an estimate before rent, tools and other '
                                    'overhead.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.period,
    required this.ticketCount,
    required this.staffCount,
    required this.netEstimateCents,
    required this.gstCents,
    required this.pstCents,
    required this.onPeriodChanged,
  });

  final FinancialPeriod period;
  final int ticketCount;
  final int staffCount;
  final int netEstimateCents;

  /// `null` hides that tax row, so a shop that never enabled PST does not see
  /// an empty PST figure.
  final int? gstCents;
  final int? pstCents;
  final ValueChanged<FinancialPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _FinancialPageState._maxContentWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        size: 26,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Financial',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      '$ticketCount closed · $staffCount staff',
                    ),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  Chip(
                    key: const Key('financial-header-net'),
                    label: Text(
                      'Net ${_money(netEstimateCents)}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: _profitColor(context, netEstimateCents),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  if (gstCents != null)
                    Chip(
                      key: const Key('financial-header-gst'),
                      label: Text('GST ${_money(gstCents!)}'),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  if (pstCents != null)
                    Chip(
                      key: const Key('financial-header-pst'),
                      label: Text('PST ${_money(pstCents!)}'),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final option in FinancialPeriod.values)
                    ChoiceChip(
                      key: Key('financial-period-${option.name}'),
                      label: Text(option.label),
                      selected: option == period,
                      onSelected: (_) => onPeriodChanged(option),
                    ),
                  FilledButton.tonalIcon(
                    key: const Key('financial-year-toggle'),
                    onPressed: () => onPeriodChanged(
                      period == FinancialPeriod.thisYear
                          ? FinancialPeriod.thisMonth
                          : FinancialPeriod.thisYear,
                    ),
                    icon: Icon(
                      period == FinancialPeriod.thisYear
                          ? Icons.calendar_month_outlined
                          : Icons.calendar_today_outlined,
                    ),
                    label: Text(
                      period == FinancialPeriod.thisYear
                          ? 'Monthly view'
                          : 'Yearly view',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.revenueCents,
    required this.costCents,
    required this.grossProfitCents,
    required this.staffPayCents,
    required this.netEstimateCents,
    required this.tracked,
    required this.ticketCount,
    required this.gstCents,
    required this.pstCents,
    required this.gstRateBp,
    required this.pstRateBp,
  });

  final int revenueCents;
  final int costCents;
  final int grossProfitCents;
  final int staffPayCents;
  final int netEstimateCents;
  final Duration tracked;
  final int ticketCount;
  final int? gstCents;
  final int? pstCents;
  final int? gstRateBp;
  final int? pstRateBp;

  @override
  Widget build(BuildContext context) {
    final margin = revenueCents <= 0
        ? 'No closed revenue'
        : '${(grossProfitCents * 100 / revenueCents).round()}% gross margin';
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryCard(
          icon: Icons.receipt_long_outlined,
          label: 'Revenue',
          value: _money(revenueCents),
          note: '$ticketCount closed ticket${ticketCount == 1 ? '' : 's'}',
        ),
        if (gstCents != null)
          _SummaryCard(
            icon: Icons.percent,
            label: 'GST',
            value: _money(gstCents!),
            note: gstRateBp == null
                ? 'Collected on closed tickets'
                : '${formatTaxRate(gstRateBp!)} on taxable sales',
          ),
        if (pstCents != null)
          _SummaryCard(
            icon: Icons.percent,
            label: 'PST',
            value: _money(pstCents!),
            note: pstRateBp == null
                ? 'Collected on closed tickets'
                : '${formatTaxRate(pstRateBp!)} on taxable sales',
          ),
        _SummaryCard(
          icon: Icons.inventory_2_outlined,
          label: 'Parts & merch cost',
          value: _money(costCents),
          note: 'Recorded bill costs',
        ),
        _SummaryCard(
          icon: Icons.trending_up,
          label: 'Gross profit',
          value: _money(grossProfitCents),
          note: margin,
          valueColor: _profitColor(context, grossProfitCents),
        ),
        _SummaryCard(
          icon: Icons.punch_clock_outlined,
          label: 'Staff pay',
          value: _money(staffPayCents),
          note: '${_formatDuration(tracked)} tracked',
        ),
        _SummaryCard(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Net estimate',
          value: _money(netEstimateCents),
          note: 'Gross profit − staff pay',
          valueColor: _profitColor(context, netEstimateCents),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String note;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 174,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(note, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _StaffRow = ({
  FinancialStaff staff,
  Duration hours,
  int? payCents,
});

List<_StaffRow> _staffRows(
  List<FinancialStaff> staff,
  DateTime? from,
  DateTime now,
) {
  final rows = <_StaffRow>[
    for (final member in staff)
      (
        staff: member,
        hours: member.trackedIn(from, now),
        payCents: null,
      ),
  ];
  final withPay = [
    for (final row in rows)
      (
        staff: row.staff,
        hours: row.hours,
        payCents: row.staff.payCentsFor(row.hours),
      ),
  ];
  withPay.sort((a, b) {
    final byHours = b.hours.compareTo(a.hours);
    if (byHours != 0) return byHours;
    return a.staff.name.toLowerCase().compareTo(b.staff.name.toLowerCase());
  });
  return withPay;
}

class _StaffRowCard extends StatelessWidget {
  const _StaffRowCard({
    required this.row,
    required this.period,
    required this.database,
  });

  final _StaffRow row;
  final FinancialPeriod period;
  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = row.staff;
    final details = [
      if (member.job.isNotEmpty) member.job,
      member.hourlyRateCents > 0
          ? '${_money(member.hourlyRateCents)}/hr'
          : 'No pay rate',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('financial-staff-${member.id}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StaffHoursPage(
              staffId: member.id,
              staffName: member.name,
              database: database,
            ),
          ),
        ),
        leading: CircleAvatar(
          child: Text(
            _initials(member.name),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(member.name, style: theme.textTheme.titleSmall),
            if (member.isClockedIn)
              Chip(
                label: const Text('On the clock'),
                visualDensity: VisualDensity.compact,
                labelStyle: theme.textTheme.labelSmall,
                side: BorderSide(color: theme.colorScheme.primary),
              ),
            if (!member.isActive)
              Chip(
                label: const Text('Inactive'),
                visualDensity: VisualDensity.compact,
                labelStyle: theme.textTheme.labelSmall,
              ),
          ],
        ),
        subtitle: Text(
          '${period.label} · $details',
          style: theme.textTheme.bodySmall,
        ),
        trailing: SizedBox(
          width: 104,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDuration(row.hours),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                row.payCents == null ? 'No pay rate' : _money(row.payCents!),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClosedTicketCard extends StatelessWidget {
  const _ClosedTicketCard({required this.ticket});

  final FinancialTicket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('financial-ticket-${ticket.ticketId}'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TicketDetailPage(ticketId: ticket.ticketId),
          ),
        ),
        title: Text('${ticket.number} · ${ticket.customerName}'),
        subtitle: Text(
          '${ticket.device}\n'
          'Closed ${shortDate(ticket.closedAt)} · '
          'cost ${_money(ticket.costCents)}',
          style: theme.textTheme.bodySmall,
        ),
        isThreeLine: true,
        trailing: SizedBox(
          width: 116,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _money(ticket.revenueCents),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_money(ticket.profitCents)} profit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _profitColor(context, ticket.profitCents),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.secondary,
    this.valueColor,
  });

  final String label;
  final String value;
  final String secondary;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            secondary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _profitColor(BuildContext context, int cents) =>
    cents < 0 ? Theme.of(context).colorScheme.error : const Color(0xFF2E7D32);

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

String _money(int cents) {
  final sign = cents < 0 ? '-' : '';
  return '$sign\$${(cents.abs() / 100).toStringAsFixed(2)}';
}

String _formatDuration(Duration duration) {
  if (duration.inSeconds < 60) return '${duration.inSeconds}s';
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (hours == 0) return '${minutes}m';
  return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
}
