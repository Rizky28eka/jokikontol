import 'package:flutter/material.dart';

class Utils {
  // Show a snack bar message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    Color backgroundColor = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  // Format date to Indonesian format
  static String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Format currency in Indonesian Rupiah
  static String formatCurrency(int amount) {
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  // Get initials from full name
  static String getInitials(String fullName) {
    List<String> nameParts = fullName.split(' ');
    String initials = '';
    
    for (int i = 0; i < nameParts.length; i++) {
      if (nameParts[i].isNotEmpty) {
        initials += nameParts[i][0].toUpperCase();
      }
    }
    
    return initials;
  }
}