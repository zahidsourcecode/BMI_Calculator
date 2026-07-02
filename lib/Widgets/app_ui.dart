import 'package:flutter/material.dart';
import '../constants.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
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
  });

  final Widget body;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: title != null || leading != null || actions != null
          ? AppBar(
              title: title != null
                  ? Text(title!, style: TextStyle(fontSize: AppText.scale(context, 17)))
                  : null,
              leading: leading,
              actions: actions,
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
    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.only(bottom: AppSpacing.scale(context, 14)),
      padding: padding ?? AppSpacing.cardPadding(context),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius(context, 20)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.12),
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
    final fillColor = backgroundColor ?? AppColors.primary;
    final disabledFillColor = disabledBackgroundColor ?? AppColors.border;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          backgroundColor: enabled ? fillColor : disabledFillColor,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: disabledFillColor,
          disabledForegroundColor: AppColors.onPrimary,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.scale(context, 16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius(context, 16)),
          ),
          side: borderColor != null
              ? BorderSide(color: borderColor!.withValues(alpha: 0.7))
              : BorderSide.none,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSpacing.icon(context, 20)),
              AppSpacing.gapH(context, 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: AppText.scale(context, 15),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
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
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.7)),
          padding: EdgeInsets.symmetric(vertical: AppSpacing.scale(context, 14)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius(context, 16)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSpacing.icon(context, 18)),
              AppSpacing.gapH(context, 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppText.scale(context, 14),
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.scale(context, 16),
            horizontal: AppSpacing.scale(context, 10),
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radius(context, 16)),
            border: Border.all(
              color: selected
                  ? AppColors.textPrimary.withValues(alpha: 0.7)
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.onPrimary : AppColors.textOnCardMuted,
                size: AppSpacing.icon(context, 52),
              ),
              AppSpacing.gap(context, 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.onPrimary : AppColors.textOnCardMuted,
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
    return Material(
      color: AppColors.surfaceLight,
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
            color: onTap != null ? AppColors.textOnCard : AppColors.border,
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
