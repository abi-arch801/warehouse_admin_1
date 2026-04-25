import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — GudangPro Admin · Orange (Jeruk) Theme
// Versi admin dari GudangPro. Pakai AppTheme.buildTheme() di MaterialApp,
// dan AppTheme.<color> di widget.
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Palet Oranye ────────────────────────────────────────────────────────────
  static const Color primaryDark    = Color(0xFFE65100); // oranye tua
  static const Color primary        = Color(0xFFFB8C00); // oranye utama
  static const Color primaryMid     = Color(0xFFFF9800); // oranye tengah
  static const Color primaryLight   = Color(0xFFFFB74D); // oranye muda
  static const Color primaryLighter = Color(0xFFFFCC80); // oranye lebih muda
  static const Color primaryPale    = Color(0xFFFFE0B2); // oranye pucat
  static const Color primarySurface = Color(0xFFFFF3E0); // oranye surface
  static const Color background     = Color(0xFFFFF8F0); // oranye sangat muda

  // ── Warna Teks ──────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFBF360C); // teks utama oranye gelap
  static const Color textDark    = Color(0xFF3E2723); // teks sangat gelap (cokelat)

  // ── Status ──────────────────────────────────────────────────────────────────
  static const Color statusApproved  = Color(0xFF2E7D32);
  static const Color statusPending   = Color(0xFFFFB300);
  static const Color statusRejected  = Color(0xFFD32F2F);
  static const Color statusCompleted = Color(0xFF1B5E20);
  static const Color statusInfo      = Color(0xFFFB8C00);

  // ── Background Status ────────────────────────────────────────────────────────
  static const Color bgApproved  = Color(0xFFE8F5E9);
  static const Color bgPending   = Color(0xFFFFF8E1);
  static const Color bgRejected  = Color(0xFFFFEBEE);
  static const Color bgCompleted = Color(0xFFE8F5E9);
  static const Color bgInfo      = Color(0xFFFFF3E0);

  // ── Gradien Utama ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryMid, primaryLighter],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  // ── SystemUiOverlayStyle ─────────────────────────────────────────────────────
  static const SystemUiOverlayStyle lightOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  // ── ThemeData ────────────────────────────────────────────────────────────────
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primarySurface,
        onPrimaryContainer: textPrimary,
        secondary: primaryLight,
        onSecondary: Colors.white,
        secondaryContainer: primaryPale,
        onSecondaryContainer: textPrimary,
        surface: Colors.white,
        onSurface: textPrimary,
        background: background,
        onBackground: textPrimary,
        error: statusRejected,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: lightOverlay,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0x99FB8C00),
          elevation: 8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0x33FFB74D), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: statusRejected, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: statusRejected, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        iconColor: primary,
        prefixIconColor: primary,
        hintStyle: TextStyle(fontSize: 14),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryDark,
          letterSpacing: 0.3,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: Colors.grey, width: 1.5),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primarySurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
