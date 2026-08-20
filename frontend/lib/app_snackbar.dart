import 'package:flutter/material.dart';
import 'theme.dart';

class AppSnackbar {
  static void _show(
    BuildContext context, {
    required String message,
    required Color color,
    required IconData icon,
  }) {
    // ScaffoldMessenger clears any active snackbars so alerts don't pile up
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating, // Floats above bottom navigations
        backgroundColor: AppTheme.surfaceAlt,
        margin: const EdgeInsets.all(16), // Padding separating it from screen edges
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withOpacity(0.4), width: 1),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) => _show(
    context,
    message: message,
    color: AppTheme.success,
    icon: Icons.check_circle_rounded,
  );

  static void error(BuildContext context, String message) => _show(
    context,
    message: message,
    color: AppTheme.danger,
    icon: Icons.error_rounded,
  );

  static void info(BuildContext context, String message) => _show(
    context,
    message: message,
    color: AppTheme.accent,
    icon: Icons.info_rounded,
  );
}
