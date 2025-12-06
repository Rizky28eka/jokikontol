import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomCheckboxGroup<T> extends StatelessWidget {
  final String name;
  final String label;
  final String? tooltip;
  final List<FormBuilderFieldOption<T>> options;
  final bool required;
  final ValueChanged<List<T>?>? onChanged;
  final Axis orientation;

  const CustomCheckboxGroup({
    super.key,
    required this.name,
    required this.label,
    this.tooltip,
    required this.options,
    this.required = false,
    this.onChanged,
    this.orientation = Axis.vertical,
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
          FormBuilderCheckboxGroup<T>(
            name: name,
            options: options,
            orientation: orientation == Axis.vertical ? OptionsOrientation.vertical : OptionsOrientation.horizontal,
            validator: (value) {
              if (required && (value == null || value.isEmpty)) {
                return 'Pilih setidaknya satu $label';
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