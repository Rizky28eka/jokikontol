import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomTextField extends StatelessWidget {
  final String name;
  final String label;
  final String? hintText;
  final String? tooltip;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool required;
  final List<String? Function(String?)>? validators;
  final ValueChanged<String?>? onChanged;

  const CustomTextField({
    super.key,
    required this.name,
    required this.label,
    this.hintText,
    this.tooltip,
    this.maxLines = 1,
    this.keyboardType,
    this.required = false,
    this.validators,
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
          FormBuilderTextField(
            name: name,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              alignLabelWithHint: maxLines != 1,
            ),
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: (value) {
              if (required && (value == null || value.isEmpty)) {
                return '$label wajib diisi';
              }
              if (validators != null) {
                for (final validator in validators!) {
                  final error = validator(value);
                  if (error != null) return error;
                }
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