import 'package:flutter/material.dart';
import '../Services/theme_controller.dart';
import '../constants.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.backgroundTop, colors.backgroundBottom],
        ),
      ),
      child: child,
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.leading,
    this.actions,
    this.showThemeBar = false,
  });

  final Widget body;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showThemeBar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeController = AppThemeScope.of(context);
    final appBarActions = [
      ...?actions,
      IconButton(
        tooltip: themeController.isDark ? 'Light mode' : 'Dark mode',
        icon: Icon(
          themeController.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: colors.textPrimary,
        ),
        onPressed: themeController.toggle,
      ),
      AppSpacing.gapH(context, 4),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: title != null || leading != null || actions != null || showThemeBar
          ? AppBar(
              title: title != null
                  ? Text(
                      title!,
                      style: TextStyle(
                        fontSize: AppText.scale(context, 17),
                        color: colors.textPrimary,
                      ),
                    )
                  : null,
              leading: leading,
              actions: appBarActions,
            )
          : null,
      body: AppBackground(child: SafeArea(child: body)),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.margin,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.only(bottom: AppSpacing.scale(context, 14)),
      padding: padding ?? AppSpacing.cardPadding(context),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius(context, 20)),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.primaryDark.withValues(alpha: 0.12),
            blurRadius: AppSpacing.scale(context, 16),
            offset: Offset(0, AppSpacing.scale(context, 6)),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.scale(context, 12)),
      child: Text(text, style: AppText.headline(context)),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.icon,
    this.borderColor,
    this.backgroundColor,
    this.disabledBackgroundColor,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final IconData? icon;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fillColor = backgroundColor ?? colors.button;
    final disabledFillColor = disabledBackgroundColor ?? colors.button.withValues(alpha: 0.55);
    final border = BorderSide(
      color: (borderColor ?? colors.textPrimary).withValues(alpha: 0.7),
    );

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: enabled ? fillColor : disabledFillColor,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: disabledFillColor,
          disabledForegroundColor: colors.onPrimary,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.scale(
              context,
              AppSpacing.isCompact(context) ? 13 : 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius(context, 16)),
          ),
          side: border,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSpacing.icon(context, 20), color: colors.onPrimary),
              AppSpacing.gapH(context, 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: AppText.scale(context, 15),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: colors.button,
          foregroundColor: colors.onPrimary,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.scale(
              context,
              AppSpacing.isCompact(context) ? 11 : 14,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius(context, 16)),
          ),
          side: BorderSide(color: colors.textPrimary.withValues(alpha: 0.7)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSpacing.icon(context, 18), color: colors.onPrimary),
              AppSpacing.gapH(context, 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppText.scale(context, 14),
                color: colors.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenderChip extends StatelessWidget {
  const GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.scale(context, 10),
            horizontal: AppSpacing.scale(context, 8),
          ),
          decoration: BoxDecoration(
            color: selected ? colors.button : colors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radius(context, 16)),
            border: Border.all(
              color: selected
                  ? colors.textPrimary.withValues(alpha: 0.7)
                  : colors.border,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? colors.onPrimary : colors.textOnCardMuted,
                size: AppSpacing.icon(
                  context,
                  AppSpacing.isCompact(context) ? 44 : 52,
                ),
              ),
              AppSpacing.gap(context, 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? colors.onPrimary : colors.textOnCardMuted,
                  fontSize: AppText.scale(context, 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepperControl extends StatelessWidget {
  const StepperControl({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.minValue = 0,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final int minValue;

  @override
  Widget build(BuildContext context) {
    final buttonSize = AppSpacing.scale(context, 48);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundButton(
          icon: Icons.remove,
          size: buttonSize,
          onTap: value > minValue ? onDecrement : null,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.scale(context, 28)),
          child: Text('$value', style: AppText.cardValue(context)),
        ),
        _RoundButton(icon: Icons.add, size: buttonSize, onTap: onIncrement),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: onTap != null ? colors.button : colors.surfaceLight,
      borderRadius: BorderRadius.circular(AppSpacing.radius(context, 14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius(context, 14)),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: AppSpacing.icon(context, 22),
            color: onTap != null ? colors.onPrimary : colors.border,
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.color,
    this.backgroundColor,
    this.fontSize,
    this.padding,
  });

  final String label;
  final Color color;
  final Color? backgroundColor;
  final double? fontSize;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: AppSpacing.scale(context, 14),
            vertical: AppSpacing.scale(context, 6),
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: AppText.scale(context, fontSize ?? 12),
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

void openHistory(BuildContext context) {
  Navigator.pushNamed(context, '/history');
}

class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    required this.child,
    this.padding,
    this.scrollable = true,
    this.avoidKeyboard = true,
  });

  final Widget child;
  final EdgeInsets? padding;
  final bool scrollable;
  final bool avoidKeyboard;

  @override
  Widget build(BuildContext context) {
    final bottomInset = avoidKeyboard ? MediaQuery.viewInsetsOf(context).bottom : 0.0;
    final edgePadding = (padding ?? EdgeInsets.zero).add(
      EdgeInsets.only(bottom: bottomInset),
    );

    final content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppSpacing.contentMaxWidth(context)),
        child: child,
      ),
    );

    if (!scrollable) {
      return Padding(
        padding: edgePadding,
        child: content,
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: edgePadding,
      child: content,
    );
  }
}

class AppToastBanner extends StatelessWidget {
  const AppToastBanner({
    required this.message,
    required this.shakeOffset,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final String message;
  final double shakeOffset;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = AppSpacing.radius(context, 12);

    return Transform.translate(
      offset: Offset(shakeOffset, 0),
      child: Material(
        elevation: AppSpacing.scale(context, 8),
        shadowColor: colors.primaryDark.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor ?? colors.button,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? colors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          padding: AppSpacing.toastPadding(context),
          child: Text(
            message,
            style: TextStyle(
              color: textColor ?? colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: AppText.scale(context, 15),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
