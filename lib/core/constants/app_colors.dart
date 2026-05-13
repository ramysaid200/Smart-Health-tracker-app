// Core color palette for Smart Health Tracker
// Dark theme with vibrant purple accent
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141824);
  static const Color surfaceVariant = Color(0xFF1A2035);
  static const Color cardBg = Color(0xFF141824);

  // Accent / Primary
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF8B7FFF);
  static const Color primaryDark = Color(0xFF5040C0);
  static const Color primaryGlow = Color(0x336C5CE7);

  // Status Colors
  static const Color success = Color(0xFF00D9A3);
  static const Color successLight = Color(0x2600D9A3);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color warningLight = Color(0x26FDCB6E);
  static const Color error = Color(0xFFFF6B9D);
  static const Color errorLight = Color(0x26FF6B9D);
  static const Color info = Color(0xFF74B9FF);
  static const Color infoLight = Color(0x2674B9FF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8F92A1);
  static const Color textHint = Color(0xFF4A4F5E);
  static const Color textDisabled = Color(0xFF3A3F4E);

  // Borders
  static const Color borderSubtle = Color(0xFF1F2937);
  static const Color borderMedium = Color(0xFF2D3748);
  static const Color borderStrong = Color(0xFF4A5568);

  // Metric Colors
  static const Color stepsColor = Color(0xFF6C5CE7);    // purple
  static const Color waterColor = Color(0xFF74B9FF);     // blue
  static const Color caloriesColor = Color(0xFFFF7675);  // red/pink
  static const Color sleepColor = Color(0xFFA29BFE);     // lavender
  static const Color weightColor = Color(0xFF00D9A3);    // mint
  static const Color heartColor = Color(0xFFFF6B9D);     // pink
  static const Color nutritionColor = Color(0xFFFDCB6E); // yellow
  static const Color workoutColor = Color(0xFFFF7675);   // orange-red

  // Macro Colors
  static const Color carbsColor = Color(0xFF6C5CE7);
  static const Color proteinColor = Color(0xFF00D9A3);
  static const Color fatsColor = Color(0xFFFDCB6E);

  // Gradient
  static const List<Color> primaryGradient = [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
  static const List<Color> backgroundGradient = [Color(0xFF0A0E1A), Color(0xFF1A1F3A)];
  static const List<Color> cardGradient = [Color(0xFF141824), Color(0xFF1A2035)];
  static const List<Color> successGradient = [Color(0xFF00D9A3), Color(0xFF00B894)];
  static const List<Color> warningGradient = [Color(0xFFFDCB6E), Color(0xFFE17055)];

  // Shadow
  static const Color shadowColor = Color(0x806C5CE7);
  static const Color cardShadow = Color(0x40000000);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFF1F2937);
  static const Color shimmerHighlight = Color(0xFF2D3748);

  // Sleep Quality Colors
  static const Color sleepPoor = Color(0xFFFF6B9D);
  static const Color sleepFair = Color(0xFFFDCB6E);
  static const Color sleepGood = Color(0xFF00D9A3);
  static const Color sleepExcellent = Color(0xFF6C5CE7);

  // Blood Pressure Range Colors
  static const Color bpNormal = Color(0xFF00D9A3);
  static const Color bpElevated = Color(0xFFFDCB6E);
  static const Color bpHigh = Color(0xFFFF6B9D);

  // BMI Range Colors
  static const Color bmiUnderweight = Color(0xFF74B9FF);
  static const Color bmiNormal = Color(0xFF00D9A3);
  static const Color bmiOverweight = Color(0xFFFDCB6E);
  static const Color bmiObese = Color(0xFFFF6B9D);

  // Transparent
  static const Color transparent = Colors.transparent;
}
