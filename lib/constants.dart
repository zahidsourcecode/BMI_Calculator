import 'package:flutter/material.dart';

class AppColors {
  static const backgroundTop = Color(0xFF4EBDD3);
  static const backgroundBottom = Color(0xFF45B3C8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFEAF7FA);
  static const border = Color(0xFFB8E4EC);
  static const primary = Color(0xFF4EBDD3);
  static const primaryDark = Color(0xFF1A6B7A);
  static const success = Color(0xFF1A8F5C);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC4C4C);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textMuted = Color(0xE6FFFFFF);
  static const textOnCard = Color(0xFF12333D);
  static const textOnCardMuted = Color(0xFF4A6670);
  static const onPrimary = Color(0xFFFFFFFF);
}

class AppSpacing {
  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  static double page(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 340) return 12;
    if (width < 360) return 16;
    return 20;
  }

  static double scale(BuildContext context, double value) {
    final size = MediaQuery.sizeOf(context);
    final widthFactor = (size.width / _designWidth).clamp(0.82, 1.15);
    final heightFactor = (size.height / _designHeight).clamp(0.85, 1.1);
    return value * (widthFactor * 0.7 + heightFactor * 0.3);
  }

  static double icon(BuildContext context, double value) => scale(context, value);

  static double radius(BuildContext context, double value) => scale(context, value);

  static SizedBox gap(BuildContext context, double height) =>
      SizedBox(height: scale(context, height));

  static SizedBox gapH(BuildContext context, double width) =>
      SizedBox(width: scale(context, width));

  static EdgeInsets cardPadding(BuildContext context) =>
      EdgeInsets.all(scale(context, 20));

  static double photoSize(BuildContext context, {double base = 240}) {
    final height = MediaQuery.sizeOf(context).height;
    return scale(context, base).clamp(160, height * 0.28);
  }
}

class AppText {
  static double scale(BuildContext context, double size) =>
      AppSpacing.scale(context, size);

  static TextStyle display(BuildContext context) => TextStyle(
        fontSize: scale(context, 32),
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle headline(BuildContext context) => TextStyle(
        fontSize: scale(context, 20),
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: scale(context, 15),
        color: AppColors.textMuted,
        height: 1.45,
      );

  static TextStyle cardHeadline(BuildContext context) => TextStyle(
        fontSize: scale(context, 20),
        fontWeight: FontWeight.w600,
        color: AppColors.textOnCard,
      );

  static TextStyle cardBody(BuildContext context) => TextStyle(
        fontSize: scale(context, 15),
        color: AppColors.textOnCardMuted,
        height: 1.45,
      );

  static TextStyle cardLabel(BuildContext context) => TextStyle(
        fontSize: scale(context, 12),
        fontWeight: FontWeight.w600,
        color: AppColors.textOnCardMuted,
        letterSpacing: 0.8,
      );

  static TextStyle cardValue(BuildContext context) => TextStyle(
        fontSize: scale(context, 40),
        fontWeight: FontWeight.w700,
        color: AppColors.textOnCard,
        height: 1,
      );
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundTop,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryDark,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSurface: AppColors.textOnCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primaryDark,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryDark,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.primaryDark,
      overlayColor: AppColors.primaryDark.withValues(alpha: 0.12),
      trackHeight: 4,
    ),
  );
}
