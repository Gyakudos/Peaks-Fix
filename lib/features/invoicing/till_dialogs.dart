import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/database.dart';
import '../../data/till.dart';
import '../../shell/app_access.dart';

/// Coin and bill count entry. Reports the running count on every change.
class _CountGrid extends StatefulWidget {
  const _CountGrid({required this.onChanged});

  final ValueChanged<Map<int, int>> onChanged;

  @override
  State<_CountGrid> createState() => _CountGridState();
}

class _CountGridState extends State<_CountGrid> {
  final _controllers = {
    for (final d in [...tillCoins, ...tillBills])
      d.cents: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _changed() => widget.onChanged({
        for (final e in _controllers.entries)
          e.key: int.tryParse(e.value.text) ?? 0,
      });

  Widget _column(String title, List<TillDenomination> items) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            for (final d in items)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  key: Key('till-count-${d.cents}'),
                  controller: _controllers[d.cents],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _changed(),
                  decoration: InputDecoration(
                    labelText: d.label,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _column('Coins', tillCoins),
          const SizedBox(width: 16),
          _column('Bills', tillBills),
        ],
      );
}

String _staffName(BuildContext context) =>
    AppSessionScope.maybeOf(context)?.user?.name ?? 'Shop';

/// Counts the till, records a deposit, closes the day and signs everyone out.
Future<bool> showCloseDayDialog(BuildContext context) async {
  final session = AppSessionScope.maybeOf(context);
  final by = _staffName(context);
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _CloseDayDialog(by: by),
  );
  if (saved == true) session?.signOut();
  return saved == true;
}

class _CloseDayDialog extends StatefulWidget {
  const _CloseDayDialog({required this.by});

  final String by;

  @override
  State<_CloseDayDialog> createState() => _CloseDayDialogState();
}

class _CloseDayDialogState extends State<_CloseDayDialog> {
  final _deposit = TextEditingController();
  List<TillEvent>? _log;
  TillTakings _takings = const TillTakings();
  Map<int, int> _counts = const {};
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _deposit.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = AppDatabase.instance;
    final log = await loadTillLog(db);
    final takings = await loadTakingsSinceClose(db, log);
    if (mounted) {
      setState(() {
        _log = log;
        _takings = takings;
      });
    }
  }

  int get _depositCents =>
      ((double.tryParse(_deposit.text.trim()) ?? 0) * 100).round();

  Future<void> _close() async {
    final counted = tallyCents(_counts);
    if (_depositCents < 0 || _depositCents > counted) {
      setState(() => _error = 'Deposit cannot be more than the counted cash.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await addTillEvent(
        AppDatabase.instance,
        TillEvent(
          type: TillEventType.close,
          at: DateTime.now(),
          by: widget.by,
          counts: _counts,
          expectedCents: expectedOpeningCents(_log!) + _takings.cashCents,
          depositCents: _depositCents,
          takings: _takings,
        ),
      );
      await clockOutAllStaff(AppDatabase.instance);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not close the day: $error';
        });
      }
    }
  }

  Widget _line(String label, int cents, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              tillMoney(cents),
              style: bold ? const TextStyle(fontWeight: FontWeight.w700) : null,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final log = _log;
    final counted = tallyCents(_counts);
    final expected =
        log == null ? 0 : expectedOpeningCents(log) + _takings.cashCents;
    final variance = counted - expected;
    final kept = counted - _depositCents;
    return AlertDialog(
      title: const Text('Close Day'),
      content: SizedBox(
        width: 520,
        child: log == null
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Takings (net of refunds)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    _line('Cash', _takings.cashCents),
                    _line('Card', _takings.cardCents),
                    _line('E-transfer', _takings.eTransferCents),
                    if (_takings.otherCents != 0)
                      _line('Other', _takings.otherCents),
                    _line('Total', _takings.totalCents, bold: true),
                    const Divider(height: 24),
                    _line('Opening float', expectedOpeningCents(log)),
                    _line('Expected cash in till', expected, bold: true),
                    const SizedBox(height: 16),
                    _CountGrid(
                      onChanged: (counts) => setState(() => _counts = counts),
                    ),
                    const SizedBox(height: 12),
                    _line('Counted', counted, bold: true),
                    Text(
                      variance == 0
                          ? 'Till balances.'
                          : variance > 0
                              ? 'Over by ${tillMoney(variance)}'
                              : 'Short by ${tillMoney(-variance)}',
                      key: const Key('till-variance'),
                      style: TextStyle(
                        color: variance == 0
                            ? Colors.green.shade700
                            : Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('till-deposit'),
                      controller: _deposit,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Bank deposit (\$)',
                        helperText: 'Taken out of the till for the bank',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _line('Left in till for tomorrow', kept, bold: true),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Closing the day clocks out all staff and signs out '
                      'everyone on this computer.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('till-close-confirm'),
          onPressed: _saving || log == null ? null : _close,
          child: const Text('Close Day'),
        ),
      ],
    );
  }
}

/// Counts the till and checks it against what was left last night.
Future<bool> showOpenDayDialog(BuildContext context) async {
  final by = _staffName(context);
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => _OpenDayDialog(by: by),
  );
  return saved == true;
}

class _OpenDayDialog extends StatefulWidget {
  const _OpenDayDialog({required this.by});

  final String by;

  @override
  State<_OpenDayDialog> createState() => _OpenDayDialogState();
}

class _OpenDayDialogState extends State<_OpenDayDialog> {
  final _note = TextEditingController();
  List<TillEvent>? _log;
  Map<int, int> _counts = const {};
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    loadTillLog(AppDatabase.instance).then((log) {
      if (mounted) setState(() => _log = log);
    });
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _open(int expected) async {
    final variance = tallyCents(_counts) - expected;
    if (variance != 0 && _note.text.trim().isEmpty) {
      setState(() => _error = 'Add a note explaining the difference.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await addTillEvent(
        AppDatabase.instance,
        TillEvent(
          type: TillEventType.open,
          at: DateTime.now(),
          by: widget.by,
          counts: _counts,
          expectedCents: expected,
          note: _note.text.trim(),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not open the day: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = _log;
    final expected = log == null ? 0 : expectedOpeningCents(log);
    final counted = tallyCents(_counts);
    final variance = counted - expected;
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Open Day'),
      content: SizedBox(
        width: 520,
        child: log == null
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.isEmpty
                          ? 'No earlier count on record. Count the till to '
                              'set the opening float.'
                          : 'Left in the till at the last close: '
                              '${tillMoney(expected)}. Count the till to '
                              'verify it.',
                    ),
                    const SizedBox(height: 16),
                    _CountGrid(
                      onChanged: (counts) => setState(() => _counts = counts),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Counted ${tillMoney(counted)}',
                      style: theme.textTheme.titleSmall,
                    ),
                    if (log.isNotEmpty)
                      Text(
                        variance == 0
                            ? 'Matches last night.'
                            : variance > 0
                                ? 'Over by ${tillMoney(variance)}'
                                : 'Short by ${tillMoney(-variance)}',
                        key: const Key('till-open-variance'),
                        style: TextStyle(
                          color: variance == 0
                              ? Colors.green.shade700
                              : theme.colorScheme.error,
                        ),
                      ),
                    if (log.isNotEmpty && variance != 0) ...[
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('till-open-note'),
                        controller: _note,
                        decoration: const InputDecoration(
                          labelText: 'Note about the difference',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _error!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('till-open-confirm'),
          onPressed: _saving || log == null
              ? null
              : () => _open(log.isEmpty ? counted : expected),
          child: const Text('Open Day'),
        ),
      ],
    );
  }
}
