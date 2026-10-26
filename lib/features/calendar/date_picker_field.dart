import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.required = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value == null
                  ? 'Not set'
                  : localizations.formatMediumDate(value!),
            ),
          ),
          IconButton(
            key: Key('date-picker-$label'),
            tooltip: 'Choose $label',
            visualDensity: VisualDensity.compact,
            onPressed: () async {
              final now = DateTime.now();
              final selected = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime(now.year, now.month, now.day),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selected != null) {
                onChanged(
                    DateTime(selected.year, selected.month, selected.day));
              }
            },
            icon: const Icon(Icons.calendar_today_outlined),
          ),
          if (value != null && !required)
            IconButton(
              key: Key('clear-date-$label'),
              tooltip: 'Clear $label',
              visualDensity: VisualDensity.compact,
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }
}
