import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String name;
  final String label;
  final String? tooltip;
  final List<DropdownMenuItem<T>> items;
  final bool required;
  final ValueChanged<T?>? onChanged;
  final String? hint;

  const CustomDropdown({
    super.key,
    required this.name,
    required this.label,
    this.tooltip,
    required this.items,
    this.required = false,
    this.onChanged,
    this.hint,
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
          FormBuilderDropdown<T>(
            name: name,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            items: items,
            validator: (value) {
              if (required && value == null) {
                return '$label wajib dipilih';
              }
              return null;
            },
            onChanged: onChanged,
            isExpanded: true,
            menuMaxHeight: 300,
          ),
        ],
      ),
    );
  }
}