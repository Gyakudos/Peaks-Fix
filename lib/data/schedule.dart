import 'dart:convert';

import 'database.dart';

/// A technician a job can be scheduled to (an active Admin as Tech 0, or Tech 1-3, on the roster).
class Technician {
  const Technician({required this.id, required this.name, required this.job});

  final String id;
  final String name;
  final String job;
}

/// A ticket booked to a technician on a day.
class ScheduledJob {
  const ScheduledJob({
    required this.id,
    required this.ticketId,
    required this.ticketNumber,
    required this.customerName,
    required this.techId,
    required this.techName,
    required this.date,
    this.note = '',
  });

  final String id;
  final int ticketId;
  final String ticketNumber;
  final String customerName;
  final String techId;
  final String techName;
  final DateTime date;
  final String note;

  Map<String, Object?> toJson() => {
        'id': id,
        'ticketId': ticketId,
        'ticketNumber': ticketNumber,
        'customerName': customerName,
        'techId': techId,
        'techName': techName,
        'date': '${date.year.toString().padLeft(4, '0')}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.day.toString().padLeft(2, '0')}',
        'note': note,
      };

  factory ScheduledJob.fromJson(Map<String, Object?> json) {
    final parsed = DateTime.parse(json['date'] as String);
    return ScheduledJob(
      id: json['id'] as String,
      ticketId: (json['ticketId'] as num).toInt(),
      ticketNumber: json['ticketNumber'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      techId: json['techId'] as String,
      techName: json['techName'] as String? ?? '',
      date: DateTime(parsed.year, parsed.month, parsed.day),
      note: json['note'] as String? ?? '',
    );
  }
}

const _scheduleKey = 'tech_schedule';

Future<List<ScheduledJob>> loadScheduledJobs(AppDatabase database) async {
  try {
    final decoded = jsonDecode(await database.readSetting(_scheduleKey, '[]'));
    return [
      for (final item in decoded as List<dynamic>)
        ScheduledJob.fromJson((item as Map).cast<String, Object?>()),
    ];
  } catch (_) {
    return const [];
  }
}

Future<void> saveScheduledJobs(AppDatabase database, List<ScheduledJob> jobs) =>
    database.writeSetting(
      _scheduleKey,
      jsonEncode([for (final job in jobs) job.toJson()]),
    );

/// Active Admin (shown as Tech 0) and Tech 1-3 staff, best level first.
Future<List<Technician>> loadTechnicians(AppDatabase database) async {
  try {
    final decoded =
        jsonDecode(await database.readSetting('staff_roster', '[]'));
    final techs = <Technician>[
      for (final item in decoded as List<dynamic>)
        if ((item as Map)['isActive'] as bool? ?? true)
          if (RegExp(r'^(Tech [123]|Admin)$')
              .hasMatch(item['job'] as String? ?? ''))
            Technician(
              id: item['id'] as String,
              name: item['name'] as String,
              job: item['job'] == 'Admin' ? 'Tech 0' : item['job'] as String,
            ),
    ];
    techs.sort((a, b) {
      final byJob = a.job.compareTo(b.job);
      return byJob != 0
          ? byJob
          : a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return techs;
  } catch (_) {
    return const [];
  }
}
