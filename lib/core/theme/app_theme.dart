import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors based on ALU's official website color palette
  static const Color primaryRed = Color(0xFFE63329);
  static const Color darkRed = Color(0xFFC0251B);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color backgroundWhite = Color(0xFFF8F8F8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color successGreen = Color(0xFF16A34A);

  // Status colors for application pipeline badges
  static const Color statusSubmitted = Color(0xFF3B82F6);
  static const Color statusReviewing = Color(0xFFF59E0B);
  static const Color statusAccepted = Color(0xFF16A34A);
  static const Color statusRejected = Color(0xFFDC2626);
  static const Color statusPending = Color(0xFF6B7280);
  static const Color statusVerified = Color(0xFFE63329);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        primary: primaryRed,
        secondary: darkRed,
        surface: surfaceWhite,
        error: errorRed,
      ),

      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textDark,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: textGrey,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryRed,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primaryRed, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: GoogleFonts.inter(color: textGrey),
        hintStyle: GoogleFonts.inter(color: textGrey),
      ),

      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      scaffoldBackgroundColor: backgroundWhite,
    );
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return statusSubmitted;
      case 'reviewing':
        return statusReviewing;
      case 'accepted':
        return statusAccepted;
      case 'rejected':
        return statusRejected;
      case 'verified':
        return statusVerified;
      case 'pending':
        return statusPending;
      default:
        return statusPending;
    }
  }
}