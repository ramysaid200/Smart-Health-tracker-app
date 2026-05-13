import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized TextStyle definitions using Poppins (headings) + Inter (body)
class AppTextStyles {
  AppTextStyles._();

  // Poppins Headings
  static TextStyle get h1 => GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h2 => GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get h3 => GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get h4 => GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get h5 => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  // Metric Numbers
  static TextStyle get metricXl => GoogleFonts.poppins(fontSize: 52, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.0);
  static TextStyle get metricLg => GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.0);
  static TextStyle get metricMd => GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.0);
  static TextStyle get metricSm => GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  // Inter Body
  static TextStyle get bodyLg => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6);
  static TextStyle get bodyMd => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.6);
  static TextStyle get bodySm => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5);
  static TextStyle get bodyMdSecondary => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.6);
  static TextStyle get bodySmSecondary => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // Labels
  static TextStyle get labelLg => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get labelMd => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static TextStyle get labelSm => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5);
  static TextStyle get caption => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary, letterSpacing: 0.4);

  // Buttons
  static TextStyle get buttonLg => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.5);
  static TextStyle get buttonMd => GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);

  // Misc
  static TextStyle get link => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary);
  static TextStyle get chartLabel => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get chartValue => GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get greeting => GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2);
  static TextStyle get greetingSubtitle => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get bodyXs => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.4);
  static TextStyle get buttonSm => GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get overline => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1.5);
}
