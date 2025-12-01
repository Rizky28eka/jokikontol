import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String name;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final bool required;
  final ValueChanged<T?>? onChanged;
  final String? hint;

  const CustomDropdown({
    super.key,
    required this.name,
    required this.label,
    required this.items,
    this.required = false,
    this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FormBuilderDropdown<T>(
        name: name,
        decoration: InputDecoration(
          labelText: label,
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
        hint: hint != null ? Text(hint!) : null,
      ),
    );
  }
}
