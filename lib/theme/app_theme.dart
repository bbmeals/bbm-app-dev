import 'package:flutter/material.dart';

// Updated AppColors class in app_theme.dart
class AppColors {
  static const Color primary = Color(0xFF009788);     // Teal
  static const Color secondary = Color(0xFFFF7043);   // Orange
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF9F9F9);     // Light gray surface
  static const Color cardBackground = Colors.white;
  static const Color error = Colors.red;
  static const Color text = Color(0xFF212121);        // Darker text for better contrast
  static const Color textSecondary = Color(0xFF757575); // Medium gray
  static const Color disabled = Color(0xFFE0E0E0);    // Lighter gray
  static const Color divider = Color(0xFFEEEEEE);     // Very light gray
  static const Color success = Color(0xFF4CAF50);     // Green for success states
}
class AppTypography {
  // Display styles (large headlines)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.2,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.25,
    color: AppColors.text,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    height: 1.25,
    color: AppColors.text,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.text,
  );

  // Title styles (card and section titles)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.text,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.text,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.text,
  );

  // Body styles (paragraph text)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.text,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Label styles (button, caption text)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.1,
    color: AppColors.text,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.1,
    color: AppColors.text,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );
}

// Add to app_theme.dart
class AppDecoration {
  // Card decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardDecorationLight = BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // Input decorations
  static BoxDecoration inputDecoration = BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey[300]!),
  );

  static BoxDecoration inputDecorationFocused = BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primary, width: 2),
  );

  // Button decorations
  static BoxDecoration primaryButtonDecoration = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration secondaryButtonDecoration = BoxDecoration(
    color: AppColors.secondary,
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration outlineButtonDecoration = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.primary),
  );

  // Chip decorations
  static BoxDecoration chipDecoration = BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(16),
  );

  static BoxDecoration selectedChipDecoration = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(16),
  );
}
// Add custom text styles for consistency
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 14,
    color: AppColors.text,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    color: AppColors.textSecondary,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    ),
    // Added accessibility settings
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

// Custom snackbar styling
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}