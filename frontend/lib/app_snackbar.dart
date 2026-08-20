import 'package:flutter/material.dart';

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required bool isError,
  }) {
    // ScaffoldMessenger clears any active snackbars so alerts don't pile up
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4), // Longer duration to read safely
        behavior: SnackBarBehavior.floating, // Floats above bottom navigations
        margin: const EdgeInsets.all(16), // Padding separating it from screen edges
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? const Color(0XFFD64545) : const Color(0XFF2E7D32),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white.withOpacity(0.8),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
