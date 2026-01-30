import 'package:flutter/material.dart';

class AppTheme {
  // Base Colors
  static const Color duoGreen = Color(0xFF58CC02);
  static const Color duoBlue = Color(0xFF1CB0F6);
  static const Color duoRed = Color(0xFFFF4B4B);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F7);
  static const Color borderGray = Color(0xFFE5E5E5);
  static const Color shadowGray = Color(0xFFD0D0D0);
  static const Color outlineStrong = Color(0xFF000000);
  static const Color textPrimary = Color(0xFF3C3C3C);
  static const Color textSecondary = Color(0xFF777777);

  // Semantic backgrounds
  static const Color correctBackground = Color(0xFFE9F7DD);
  static const Color incorrectBackground = Color(0xFFFFE6E6);
  static const Color selectedBackground = Color(0xFFE8F5FE);

  // Functional colors (M3新增)
  static const Color wrongBookColor = Color(0xFFFF9600);
  static const Color reportColor = Color(0xFF82C91E);
  static const Color streakColor = Color(0xFFFFC800);
  static const Color streakBackground = Color(0xFFFFF4CC);

  // Difficulty colors (M3新增)
  static const Color difficultyEasy = Color(0xFF58CC02);
  static const Color difficultyMedium = Color(0xFF1CB0F6);
  static const Color difficultyHard = Color(0xFFCE82FF);

  // Topic color mapping (M3新增)
  static const Map<String, Color> topicColors = {
    'JavaScript': Color(0xFFF7DF1E),
    'React': Color(0xFF61DAFB),
    'Vue': Color(0xFF4FC08D),
    'TypeScript': Color(0xFF3178C6),
    'Node.js': Color(0xFF339933),
    'CSS': Color(0xFF1572B6),
    'HTML': Color(0xFFE34F26),
    'Java': Color(0xFF007396),
  };

  // Dimensions
  static const double borderWidth = 2;
  static const double radiusCard = 16;
  static const double radiusPanel = 24;
  static const double radiusChip = 12;
  static const double progressHeight = 12;
  static const double miniProgressHeight = 8;

  // Motion
  static const Duration durationPress = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationProgress = Duration(milliseconds: 500);
  static const Duration durationPanel = Duration(milliseconds: 300);
  static const Duration durationElastic = Duration(milliseconds: 400);
  static const Duration durationPulse = Duration(milliseconds: 800);
  static const Curve curvePress = Curves.easeInOut;
  static const Curve curveProgress = Curves.easeOutQuart;
  static const Curve curvePanel = Curves.easeOutCubic;
  static const Curve curveElastic = Curves.elasticOut;
  static const Curve curvePulse = Curves.easeInOutSine;

  // Shadows (Duolingo-style hard shadow)
  static const BoxShadow shadowDown = BoxShadow(
    color: shadowGray,
    offset: Offset(0, 4),
    blurRadius: 0,
  );

  static const BoxShadow shadowPressed = BoxShadow(
    color: shadowGray,
    offset: Offset(0, 0),
    blurRadius: 0,
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: duoGreen,
      secondary: duoBlue,
      error: duoRed,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: background,
      foregroundColor: textPrimary,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusCard),
        side: const BorderSide(color: borderGray, width: borderWidth),
      ),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: duoGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    ),
  );
}
