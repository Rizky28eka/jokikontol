import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatelessWidget {
  final String name;
  final String label;
  final String? tooltip;
  final InputType inputType;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool required;
  final ValueChanged<DateTime?>? onChanged;

  const CustomDateTimePicker({
    super.key,
    required this.name,
    required this.label,
    this.tooltip,
    this.inputType = InputType.date,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (tooltip != null) ...[
                const SizedBox(width: 4),
                Tooltip(
                  message: tooltip,
                  child: Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          FormBuilderDateTimePicker(
            name: name,
            inputType: inputType,
            format: inputType == InputType.date ? DateFormat('dd/MM/yyyy') : DateFormat('dd/MM/yyyy HH:mm'),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            initialDate: initialDate ?? DateTime.now(),
            firstDate: firstDate ?? DateTime(2000),
            lastDate: lastDate ?? DateTime(2100),
            validator: (value) {
              if (required && value == null) {
                return '$label wajib diisi';
              }
              return null;
            },
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}