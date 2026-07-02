import 'package:flutter/material.dart';
import '../Services/theme_controller.dart';
import '../constants.dart';
import '../Widgets/app_ui.dart';
import 'landing_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.page(context);
    final logoSize = AppSpacing.scale(context, 88);
    final colors = context.colors;
    final themeController = AppThemeScope.of(context);
    final minHeight = MediaQuery.sizeOf(context).height -
        MediaQuery.paddingOf(context).vertical -
        AppSpacing.scale(context, 24);

    return AppScaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: AppSpacing.pageInsets(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: AppSpacing.contentMaxWidth(context),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: minHeight.clamp(constraints.maxHeight * 0.85, constraints.maxHeight),
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
                                    spreadRadius: AppSpacing.scale(context, 2),
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
                  ),
                ),
              );
            },
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
                    padding: EdgeInsets.all(AppSpacing.scale(context, 10)),
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
