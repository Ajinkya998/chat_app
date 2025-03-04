import 'package:flutter/material.dart';

class UiUtils {
  static void snackBar(BuildContext context,
      {required String message,
      bool isError = false,
      Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
