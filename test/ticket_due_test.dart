import 'package:flutter_test/flutter_test.dart';
import 'package:vola_fix/data/ticket_due.dart';

void main() {
  final today = DateTime(2026, 10, 28, 15);

  test('default due date is 14 days after drop-off', () {
    expect(
      defaultDueDate(DateTime(2026, 10, 28, 9)),
      DateTime(2026, 11, 11),
    );
  });

  test('urgency follows the 7, 3 and past-due thresholds', () {
    DueUrgency at(int days) => dueUrgency(
          DateTime(2026, 10, 28).add(Duration(days: days)),
          today: today,
        );

    expect(at(14), DueUrgency.normal);
    expect(at(8), DueUrgency.normal);
    expect(at(7), DueUrgency.soon);
    expect(at(4), DueUrgency.soon);
    expect(at(3), DueUrgency.urgent);
    expect(at(0), DueUrgency.urgent);
    expect(at(-1), DueUrgency.overdue);
  });
}
