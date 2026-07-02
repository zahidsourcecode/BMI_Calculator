import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.isDark,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.surface,
    required this.surfaceLight,
    required this.border,
    required this.primary,
    required this.button,
    required this.primaryDark,
    required this.success,
    required this.warning,
    required this.danger,
    required this.textPrimary,
    required this.textMuted,
    required this.textOnCard,
    required this.textOnCardMuted,
    required this.onPrimary,
    required this.badgeSurface,
  });

  final bool isDark;
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color surface;
  final Color surfaceLight;
  final Color border;
  final Color primary;
  final Color button;
  final Color primaryDark;
  final Color success;
  final Color warning;
  final Color danger;
  final Color textPrimary;
  final Color textMuted;
  final Color textOnCard;
  final Color textOnCardMuted;
  final Color onPrimary;
  final Color badgeSurface;

  static const light = AppPalette(
    isDark: false,
    backgroundTop: Color(0xFF4EBDD3),
    backgroundBottom: Color(0xFF45B3C8),
    surface: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFEAF7FA),
    border: Color(0xFFB8E4EC),
    primary: Color(0xFF4EBDD3),
    button: Color(0xFF3BADC4),
    primaryDark: Color(0xFF1A6B7A),
    success: Color(0xFF1A8F5C),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC4C4C),
    textPrimary: Color(0xFFFFFFFF),
    textMuted: Color(0xE6FFFFFF),
    textOnCard: Color(0xFF12333D),
    textOnCardMuted: Color(0xFF4A6670),
    onPrimary: Color(0xFFFFFFFF),
    badgeSurface: Color(0xFFFFFFFF),
  );

  static const dark = AppPalette(
    isDark: true,
    backgroundTop: Color(0xFF0D2229),
    backgroundBottom: Color(0xFF15353F),
    surface: Color(0xFF1E4A55),
    surfaceLight: Color(0xFF254F5C),
    border: Color(0xFF3A6270),
    primary: Color(0xFF4EBDD3),
    button: Color(0xFF3BADC4),
    primaryDark: Color(0xFF8EDAE8),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    textPrimary: Color(0xFFFFFFFF),
    textMuted: Color(0xCCFFFFFF),
    textOnCard: Color(0xFFEAF7FA),
    textOnCardMuted: Color(0xFFB8D4DC),
    onPrimary: Color(0xFFFFFFFF),
    badgeSurface: Color(0xFF254F5C),
  );

  @override
  AppPalette copyWith({
    bool? isDark,
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? surface,
    Color? surfaceLight,
    Color? border,
    Color? primary,
    Color? button,
    Color? primaryDark,
    Color? success,
    Color? warning,
    Color? danger,
    Color? textPrimary,
    Color? textMuted,
    Color? textOnCard,
    Color? textOnCardMuted,
    Color? onPrimary,
    Color? badgeSurface,
  }) {
    return AppPalette(
      isDark: isDark ?? this.isDark,
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      surface: surface ?? this.surface,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      button: button ?? this.button,
      primaryDark: primaryDark ?? this.primaryDark,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      textOnCard: textOnCard ?? this.textOnCard,
      textOnCardMuted: textOnCardMuted ?? this.textOnCardMuted,
      onPrimary: onPrimary ?? this.onPrimary,
      badgeSurface: badgeSurface ?? this.badgeSurface,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
