import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF0B0E14);
  static const surface = Color(0xFF151923);
  static const surfaceAlt = Color(0xFF1E2430);
  static const accent = Color(0xFF5B8DEF);
  static const accentDim = Color(0XFF3A5A9E);
  static const success = Color(0XFF3DD68C);
  static const danger = Color(0XFFE5566D);
  static const textPrimary = Color(0XFFEDEFF5);
  static const textSecondary  = Color(0XFF9AA3B5);


//Gradient for header
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0XFF1E2430), Color(0XFF7C6BF0)],
    begin: Alignment.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0XFF1E2430), Color(0XFF151923)],
    begin: AlignmentGeometry.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  static BoxShadow softShadow = BoxShadow(
    color: Colors.black.withOpacity(0.35),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );


  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor:AppTheme.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppTheme.accent,
        secondary: AppTheme.accent,
        surface: AppTheme.surface,
        error: AppTheme.danger,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),

      textTheme: base.textTheme.apply(
        bodyColor: AppTheme.textPrimary,
        displayColor: AppTheme.textPrimary
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:AppTheme.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          padding:  EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(14)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      cardTheme: CardThemeData(
        color: AppTheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      dividerColor: Colors.white.withOpacity(0.06),
    );
  }
}

class StatusStyle {
  static Color color(String status) {
    switch(status) {
      case 'verified':
        return AppTheme.success;
      case 'pending':
        return const Color(0XFFE5B94E);
      default:
        return AppTheme.textSecondary;
    }
  }

  static IconData icon(String status) {
    switch(status) {
      case 'verified':
        return Icons.verified_rounded;
      case 'pending':
        return Icons.hourglass_top;
      default:
        return Icons.help_outline_rounded;
    }
  }
}