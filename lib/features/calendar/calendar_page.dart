import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../data/schedule.dart';
import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../../shell/app_access.dart';
import '../tickets/ticket_detail_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _month = _today();
  DateTime _selectedDate = _today();
  List<ScheduledJob> _jobs = const [];
  bool _jobsLoaded = false;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_jobsLoaded) return;
    _jobsLoaded = true;
    _reloadJobs();
  }

  Future<void> _reloadJobs() async {
    final jobs = await ShopScope.of(context).loadScheduledJobs();
    if (mounted) setState(() => _jobs = jobs);
  }

  Future<void> _removeJob(ScheduledJob job) async {
    final repository = ShopScope.of(context);
    await repository.saveScheduledJobs([
      for (final other in _jobs)
        if (other.id != job.id) other,
    ]);
    await _reloadJobs();
  }

  Future<void> _schedule(List<TicketBoardEntry> tickets) async {
    final repository = ShopScope.of(context);
    final techs = await repository.loadTechnicians();
    if (!mounted) return;
    final job = await showDialog<ScheduledJob>(
      context: context,
      builder: (_) => _ScheduleJobDialog(
        tickets: [
          for (final ticket in tickets)
            if (_isOpen(ticket.status)) ticket,
        ],
        techs: techs,
        initialDate: _selectedDate,
      ),
    );
    if (job == null) return;
    await repository.saveScheduledJobs([..._jobs, job]);
    await _reloadJobs();
    if (mounted) {
      setState(() {
        _selectedDate = job.date;
        _month = DateTime(job.date.year, job.date.month, 1);
      });
    }
  }

  static bool _isOpen(TicketStatus status) => switch (status) {
        TicketStatus.pickedUp ||
        TicketStatus.closed ||
        TicketStatus.cancelled ||
        TicketStatus.quote =>
          false,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    final localizations = MaterialLocalizations.of(context);
    final canSchedule = AppSessionScope.accessOf(context).canSchedule;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          if (canSchedule)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: StreamBuilder<List<TicketBoardEntry>>(
                stream: repository.watchBoard(),
                builder: (context, snapshot) => FilledButton.icon(
                  key: const Key('calendar-schedule-job'),
                  onPressed:
                      snapshot.hasData ? () => _schedule(snapshot.data!) : null,
                  icon: const Icon(Icons.engineering_outlined),
                  label: const Text('Schedule job'),
                ),
              ),
            ),
        ],
      ),
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
          final selectedJobs = _jobs
              .where((job) => _sameDay(job.date, _selectedDate))
              .toList()
            ..sort((a, b) => a.techName.compareTo(b.techName));
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
                        events.any((event) => _sameDay(event.date, date)) ||
                            _jobs.any((job) => _sameDay(job.date, date));
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
                child: selectedEvents.isEmpty && selectedJobs.isEmpty
                    ? const Center(child: Text('No ticket dates on this day.'))
                    : ListView(
                        children: [
                          for (final job in selectedJobs)
                            ListTile(
                              key: Key('calendar-job-${job.id}'),
                              leading: const Icon(Icons.engineering),
                              title: Text(
                                'Scheduled · ${job.ticketNumber} · '
                                '${job.techName}',
                              ),
                              subtitle: Text(
                                [
                                  job.customerName,
                                  if (job.note.isNotEmpty) job.note,
                                ].join(' · '),
                              ),
                              trailing: canSchedule
                                  ? IconButton(
                                      key: Key('calendar-job-remove-${job.id}'),
                                      tooltip: 'Remove from schedule',
                                      onPressed: () => _removeJob(job),
                                      icon: const Icon(Icons.delete_outline),
                                    )
                                  : null,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      TicketDetailPage(ticketId: job.ticketId),
                                ),
                              ),
                            ),
                          for (final event in selectedEvents)
                            ListTile(
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
                                  builder: (_) => TicketDetailPage(
                                    ticketId: event.ticket.id,
                                  ),
                                ),
                              ),
                            ),
                        ],
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

/// Books an open ticket to a technician on a day.
class _ScheduleJobDialog extends StatefulWidget {
  const _ScheduleJobDialog({
    required this.tickets,
    required this.techs,
    required this.initialDate,
  });

  final List<TicketBoardEntry> tickets;
  final List<Technician> techs;
  final DateTime initialDate;

  @override
  State<_ScheduleJobDialog> createState() => _ScheduleJobDialogState();
}

class _ScheduleJobDialogState extends State<_ScheduleJobDialog> {
  final _note = TextEditingController();
  TicketBoardEntry? _ticket;
  Technician? _tech;
  late DateTime _date = widget.initialDate;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = _dateOnly(picked));
  }

  void _save() {
    final ticket = _ticket;
    final tech = _tech;
    if (ticket == null || tech == null) {
      setState(() => _error = 'Choose a ticket and a technician.');
      return;
    }
    Navigator.of(context).pop(
      ScheduledJob(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        ticketId: ticket.id,
        ticketNumber: ticket.number,
        customerName: ticket.customerName,
        techId: tech.id,
        techName: tech.name,
        date: _date,
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return AlertDialog(
      title: const Text('Schedule job'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<TicketBoardEntry>(
                key: const Key('schedule-ticket'),
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Ticket'),
                items: [
                  for (final ticket in widget.tickets)
                    DropdownMenuItem(
                      value: ticket,
                      child: Text(
                        '${ticket.number} · ${ticket.customerName}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _ticket = value),
              ),
              const SizedBox(height: 12),
              if (widget.techs.isEmpty)
                const Text(
                  'No technicians yet. Add staff with the job Tech 1, Tech 2 '
                  'or Tech 3 in Settings.',
                )
              else
                DropdownButtonFormField<Technician>(
                  key: const Key('schedule-tech'),
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Technician'),
                  items: [
                    for (final tech in widget.techs)
                      DropdownMenuItem(
                        value: tech,
                        child: Text('${tech.name} · ${tech.job}'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _tech = value),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('schedule-date'),
                onPressed: _pickDate,
                icon: const Icon(Icons.event),
                label: Text(localizations.formatMediumDate(_date)),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('schedule-note'),
                controller: _note,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('schedule-save'),
          onPressed: _save,
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
