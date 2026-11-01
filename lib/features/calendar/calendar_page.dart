import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../tickets/ticket_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _month = _today();
  DateTime _selectedDate = _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    final localizations = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: StreamBuilder<List<TicketBoardEntry>>(
        stream: repository.watchBoard(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load calendar dates.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = _events(snapshot.data!);
          final selectedEvents = events
              .where((event) => _sameDay(event.date, _selectedDate))
              .toList()
            ..sort((a, b) {
              final dateOrder = a.date.compareTo(b.date);
              return dateOrder != 0
                  ? dateOrder
                  : a.ticket.number.compareTo(b.ticket.number);
            });
          final daysInMonth =
              DateUtils.getDaysInMonth(_month.year, _month.month);
          final firstWeekday =
              DateTime(_month.year, _month.month, 1).weekday % 7;
          final firstOffset =
              (firstWeekday - localizations.firstDayOfWeekIndex + 7) % 7;
          final cellCount = ((firstOffset + daysInMonth + 6) ~/ 7) * 7;
          final weekCount = cellCount ~/ 7;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('calendar-previous-month'),
                      tooltip: 'Previous month',
                      onPressed: () => _moveMonth(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          localizations.formatMonthYear(_month),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('calendar-next-month'),
                      tooltip: 'Next month',
                      onPressed: () => _moveMonth(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    for (var index = 0; index < 7; index++)
                      Expanded(
                        child: Center(
                          child: Text(
                            localizations.narrowWeekdays[
                                (index + localizations.firstDayOfWeekIndex) %
                                    7],
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: weekCount * 48,
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: 48,
                  ),
                  itemCount: cellCount,
                  itemBuilder: (context, index) {
                    final day = index - firstOffset + 1;
                    final date = DateTime(_month.year, _month.month, day);
                    final inMonth = date.month == _month.month;
                    final hasEvents =
                        events.any((event) => _sameDay(event.date, date));
                    final selected = _sameDay(date, _selectedDate);
                    return Padding(
                      padding: const EdgeInsets.all(2),
                      child: Material(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          key: Key(
                              'calendar-day-${date.year}-${date.month}-${date.day}'),
                          customBorder: const CircleBorder(),
                          onTap: () => setState(() {
                            _selectedDate = date;
                            _month = DateTime(date.year, date.month, 1);
                          }),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  color: inMonth
                                      ? null
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                ),
                              ),
                              if (hasEvents)
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localizations.formatMediumDate(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              Expanded(
                child: selectedEvents.isEmpty
                    ? const Center(child: Text('No ticket dates on this day.'))
                    : ListView.builder(
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          final event = selectedEvents[index];
                          return ListTile(
                            key: Key(
                              'calendar-event-${event.ticket.id}-${event.label}',
                            ),
                            leading: const Icon(Icons.event_outlined),
                            title: Text(
                              '${event.label} · ${event.ticket.number}',
                            ),
                            subtitle: Text(
                              '${event.ticket.customerName} · '
                              '${event.ticket.deviceWithVariant}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    TicketDetailPage(ticketId: event.ticket.id),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _moveMonth(int offset) {
    setState(() {
      _month = DateTime(_month.year, _month.month + offset, 1);
      _selectedDate = DateTime(_month.year, _month.month, 1);
    });
  }

  List<_CalendarEvent> _events(List<TicketBoardEntry> tickets) => [
        for (final ticket in tickets)
          if (ticket.status != TicketStatus.quote) ...[
            _CalendarEvent(
              ticket: ticket,
              date: ticket.dropOffAt ?? _dateOnly(ticket.createdAt),
              label: 'Drop Off',
            ),
            if (ticket.technicianStartAt case final date?)
              _CalendarEvent(
                  ticket: ticket, date: date, label: 'Technician Start'),
            if (ticket.partsArriveAt case final date?)
              _CalendarEvent(ticket: ticket, date: date, label: 'Parts Arrive'),
            if (ticket.customerContactedAt case final date?)
              _CalendarEvent(
                ticket: ticket,
                date: date,
                label: 'Customer Contacted',
              ),
            if (ticket.pickedUpAt case final date?)
              _CalendarEvent(
                  ticket: ticket, date: date, label: 'Date of Pick Up'),
          ],
      ];
}

class _CalendarEvent {
  const _CalendarEvent({
    required this.ticket,
    required this.date,
    required this.label,
  });

  final TicketBoardEntry ticket;
  final DateTime date;
  final String label;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
