// lib/utils/app_constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary        = Color(0xFF1A6B3C);
  static const Color primaryLight   = Color(0xFF2E9B5A);
  static const Color primaryLighter = Color(0xFFE6F4EC);
  static const Color accent         = Color(0xFF34C76F);
  static const Color danger         = Color(0xFFE03E3E);
  static const Color dangerLight    = Color(0xFFFFF0F0);
  static const Color warning        = Color(0xFFE07B00);
  static const Color warningLight   = Color(0xFFFFF7E6);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color background     = Color(0xFFF2F4F3);
  static const Color cardBg         = Color(0xFFFFFFFF);
  static const Color textPrimary    = Color(0xFF111827);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color border         = Color(0xFFE5E7EB);
  static const Color cardShadow     = Color(0x12000000);
  static const Color divider        = Color(0xFFEEF0EF);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBg,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

class AppFormat {
  static String currency(double amount) {
    if (amount >= 1000) {
      final s = amount.toStringAsFixed(0);
      return '₹' + s.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    }
    return '₹' + amount.toStringAsFixed(0);
  }

  static String dateTime(DateTime dt) {
    const ms = ['Jan','Feb','Mar','Apr','May','Jun',
                 'Jul','Aug','Sep','Oct','Nov','Dec'];
    final h  = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mi = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${ms[dt.month - 1]} · $h:$mi $ap';
  }

  static String date(DateTime d) => dateOnly(d);

  static String dateOnly(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String relativeDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff}d ago';
    if (diff < 30) return '${(diff / 7).floor()}w ago';
    return '${(diff / 30).floor()}mo ago';
  }
}
