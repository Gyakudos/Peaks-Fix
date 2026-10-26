import 'package:flutter/material.dart';

import '../../data/shop_scope.dart';
import '../../data/tickets_repository.dart';
import '../calendar/date_picker_field.dart';

class TicketDatesPanel extends StatelessWidget {
  const TicketDatesPanel({
    super.key,
    required this.ticketId,
    this.title = 'Key dates',
  });

  final int ticketId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final repository = ShopScope.of(context);
    return StreamBuilder<TicketDetailEntry?>(
      stream: repository.watchTicket(ticketId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Could not load ticket dates.');
        }
        final ticket = snapshot.data;
        if (ticket == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final dates = ticket.dates;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            key: Key('ticket-dates-$title'),
            title: Text(title),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              for (final entry in <({String label, DateTime? date})>[
                (label: 'Drop Off', date: dates.dropOffAt),
                (
                  label: 'Technician Start Date',
                  date: dates.technicianStartAt,
                ),
                (label: 'Parts Arrive', date: dates.partsArriveAt),
                (
                  label: 'Customer Contacted',
                  date: dates.customerContactedAt,
                ),
                (label: 'Date of Pick Up', date: dates.pickedUpAt),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DatePickerField(
                    label: entry.label,
                    value: entry.date,
                    required: entry.label == 'Drop Off',
                    onChanged: (value) => _save(
                      context,
                      repository,
                      dates,
                      entry.label,
                      value,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(
    BuildContext context,
    TicketsRepository repository,
    TicketDates dates,
    String label,
    DateTime? value,
  ) async {
    final updated = TicketDates(
      dropOffAt: label == 'Drop Off' ? value : dates.dropOffAt,
      technicianStartAt:
          label == 'Technician Start Date' ? value : dates.technicianStartAt,
      partsArriveAt: label == 'Parts Arrive' ? value : dates.partsArriveAt,
      customerContactedAt:
          label == 'Customer Contacted' ? value : dates.customerContactedAt,
      pickedUpAt: label == 'Date of Pick Up' ? value : dates.pickedUpAt,
    );
    try {
      await repository.updateTicketDates(ticketId, updated);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save ticket dates: $error')),
      );
    }
  }
}
