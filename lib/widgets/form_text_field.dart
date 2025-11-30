import 'package:flutter/material.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final int maxLines;
  final TextInputType? keyboardType;
  final Function(String) onChanged;
  final String? initialValue;

  const FormTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.maxLines = 1,
    this.keyboardType,
    required this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
