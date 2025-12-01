import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class CustomCheckboxGroup<T> extends StatelessWidget {
  final String name;
  final String label;
  final List<FormBuilderFieldOption<T>> options;
  final bool required;
  final ValueChanged<List<T>?>? onChanged;
  final Axis orientation;

  const CustomCheckboxGroup({
    super.key,
    required this.name,
    required this.label,
    required this.options,
    this.required = false,
    this.onChanged,
    this.orientation = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: FormBuilderCheckboxGroup<T>(
        name: name,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none, // Checkbox group usually doesn't need a border like text field
          contentPadding: EdgeInsets.zero,
        ),
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
    );
  }
}
