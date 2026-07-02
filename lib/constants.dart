import 'package:flutter/material.dart';
import 'theme/app_palette.dart';

export 'theme/app_palette.dart';

class AppSpacing {
  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  static bool isCompact(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width < 360 || size.height < 640;
  }

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static double page(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 320) return 10;
    if (width < 340) return 12;
    if (width < 360) return 16;
    return 20;
  }

  static double scale(BuildContext context, double value) {
    final size = MediaQuery.sizeOf(context);
    final minSide = size.width < size.height ? size.width : size.height;
    final widthFactor = (size.width / _designWidth).clamp(0.72, 1.15);
    final heightFactor = (size.height / _designHeight).clamp(0.78, 1.1);
    var scaled = value * (widthFactor * 0.7 + heightFactor * 0.3);

    if (minSide < 340) {
      scaled *= 0.92;
    }
    if (isLandscape(context) && size.height < 500) {
      scaled *= 0.88;
    }
    return scaled;
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
    final effectiveBase = isCompact(context) ? base * 0.82 : base;
    return scale(context, effectiveBase).clamp(140, height * (isLandscape(context) ? 0.22 : 0.28));
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 600 ? width : scale(context, 520);
  }

  static EdgeInsets pageInsets(
    BuildContext context, {
    double top = 8,
    double bottom = 0,
  }) {
    final side = page(context);
    return EdgeInsets.fromLTRB(
      side,
      scale(context, top),
      side,
      bottom == 0 ? side : scale(context, bottom),
    );
  }

  static EdgeInsets toastPadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: scale(context, 16),
        vertical: scale(context, 12),
      );
}

class AppText {
  static double scale(BuildContext context, double size) {
    final textScaler = MediaQuery.textScalerOf(context);
    final scaled = AppSpacing.scale(context, size);
    return textScaler.scale(scaled).clamp(scaled * 0.85, scaled * 1.15);
  }

  static TextStyle display(BuildContext context) {
    final colors = context.colors;
    return TextStyle(
      fontSize: scale(context, 32),
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
      letterSpacing: -0.5,
    );
  }

  static TextStyle headline(BuildContext context) {
    final colors = context.colors;
    return TextStyle(
      fontSize: scale(context, 20),
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
  }

  static TextStyle body(BuildContext context) {
    final colors = context.colors;
    return TextStyle(
      fontSize: scale(context, 15),
      color: colors.textMuted,
      height: 1.45,
    );
  }

  static TextStyle cardHeadline(BuildContext context) {
    final colors = context.colors;
    return TextStyle(
      fontSize: scale(context, 20),
      fontWeight: FontWeight.w600,
      color: colors.textOnCard,
    );
  }

  static TextStyle cardBody(BuildContext context) {
    final colors = context.colors;
    return TextStyle(
      fontSize: scale(context, 15),
      color: colors.textOnCardMuted,
      height: 1.45,
    );
  }

  static TextStyle cardLabel(BuildContext context) {
    final colors = context.colors;
    return TextStyle(
      fontSize: scale(context, 12),
      fontWeight: FontWeight.w600,
      color: colors.textOnCardMuted,
      letterSpacing: 0.8,
    );
  }

  static TextStyle cardValue(BuildContext context) {
    final colors = context.colors;
    return TextStyle(
      fontSize: scale(context, 40),
      fontWeight: FontWeight.w700,
      color: colors.textOnCard,
      height: 1,
    );
  }
}

ThemeData buildAppTheme(AppPalette palette) {
  return ThemeData(
    useMaterial3: true,
    brightness: palette.isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: palette.backgroundTop,
    extensions: [palette],
    colorScheme: ColorScheme(
      brightness: palette.isDark ? Brightness.dark : Brightness.light,
      primary: palette.primaryDark,
      onPrimary: palette.onPrimary,
      secondary: palette.primary,
      onSecondary: palette.onPrimary,
      error: palette.danger,
      onError: palette.onPrimary,
      surface: palette.surface,
      onSurface: palette.textOnCard,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: palette.textPrimary,
      iconTheme: IconThemeData(color: palette.textPrimary),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.primaryDark,
      contentTextStyle: TextStyle(color: palette.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: palette.primaryDark,
      inactiveTrackColor: palette.border,
      thumbColor: palette.primaryDark,
      overlayColor: palette.primaryDark.withValues(alpha: 0.12),
      trackHeight: 4,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.button,
        foregroundColor: palette.onPrimary,
        disabledBackgroundColor: palette.button.withValues(alpha: 0.55),
        disabledForegroundColor: palette.onPrimary,
      ),
    ),
  );
}
