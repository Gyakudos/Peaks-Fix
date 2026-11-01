/// How many days a repair is meant to take, counted from drop-off.
const int defaultRepairDays = 14;

/// A quote with no intake is deleted this many days after it was opened.
const int quoteLifetimeDays = 14;

/// Customer name given to a quote opened without one.
const String quoteCustomerName = 'Quote';

enum DueUrgency { normal, soon, urgent, overdue }

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// The day a quote opened at [createdAt] is removed.
DateTime quoteExpiryDate(DateTime createdAt) =>
    _dateOnly(createdAt).add(const Duration(days: quoteLifetimeDays));

/// The due date a ticket gets when nobody has adjusted it.
DateTime defaultDueDate(DateTime dropOff) =>
    _dateOnly(dropOff).add(const Duration(days: defaultRepairDays));

/// Whole days from [today] until [due]; negative once the date has passed.
int daysUntilDue(DateTime due, {DateTime? today}) {
  final start = _dateOnly(today ?? DateTime.now());
  final end = _dateOnly(due);
  return DateTime.utc(end.year, end.month, end.day)
      .difference(DateTime.utc(start.year, start.month, start.day))
      .inDays;
}

/// Past due is overdue, 3 days or fewer is urgent, 7 days or fewer is soon.
DueUrgency dueUrgency(DateTime due, {DateTime? today}) {
  final days = daysUntilDue(due, today: today);
  if (days < 0) return DueUrgency.overdue;
  if (days <= 3) return DueUrgency.urgent;
  if (days <= 7) return DueUrgency.soon;
  return DueUrgency.normal;
}
