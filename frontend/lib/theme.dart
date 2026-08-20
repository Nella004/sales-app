import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF3E5C76);
  static const primaryDark = Color(0xFF1D2D44);
  static const accent = Color(0xFF00B4A6);
  static const warning = Color(0xFFE8A33D);
  static const danger = Color(0XFFD64545);
  static const background = Color(0XFFF6F8FA);
  static const cardBg  = Colors.white;
}

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background, 
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.danger,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0XFF1D2D44),
      displayColor: const Color(0XFF1D2D44)
    ),

    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding:  EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
    ),
  );
}

//color and icon for verification status
class StatusStyle {
  final Color color;
  final IconData icon;
  final String label;
  const StatusStyle(this.color, this.icon, this.label);

  static StatusStyle forVendor(String status) {
    switch(status) {
      case 'verified':
        return StatusStyle(Color(0XFF2E7D32), Icons.verified, 'Verified');
      case 'pending':
        return StatusStyle(AppColors.warning, Icons.hourglass_top,'Pending');
      default:
        return StatusStyle(Colors.grey, Icons.help_outline, 'Unverified');
    }
  }
}