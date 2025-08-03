import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loveguru/config/theme/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.surface,
    primaryColor: AppColors.primary,
    textTheme: GoogleFonts.ubuntuTextTheme(),
  );
}
