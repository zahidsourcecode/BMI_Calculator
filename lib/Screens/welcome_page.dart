import 'package:flutter/material.dart';
import '../Services/theme_controller.dart';
import '../constants.dart';
import '../Widgets/app_ui.dart';
import 'landing_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.page(context);
    final logoSize = AppSpacing.scale(context, 88);
    final colors = context.colors;
    final themeController = AppThemeScope.of(context);

    return AppScaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.scale(context, 14)),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.12),
                          blurRadius: AppSpacing.scale(context, 24),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icon/appIcon.png',
                      width: logoSize,
                      height: logoSize,
                    ),
                  ),
                ),
                AppSpacing.gap(context, 24),
                Text(
                  'Welcome to BMI Calculator',
                  style: AppText.display(context),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                SecondaryButton(
                  label: 'Measure your BMI',
                  icon: Icons.monitor_weight_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LandingPage()),
                  ),
                ),
                AppSpacing.gap(context, 12),
                SecondaryButton(
                  label: 'See history',
                  icon: Icons.history_rounded,
                  onTap: () => openHistory(context),
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: padding,
            child: SafeArea(
              child: Material(
                color: colors.button.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: themeController.toggle,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      themeController.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: colors.onPrimary,
                      size: AppSpacing.icon(context, 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
