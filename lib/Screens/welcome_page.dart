import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../Widgets/app_ui.dart';
import 'landing_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static final Uri _developerUrl = Uri.parse('https://zahid-career.vercel.app/');

  Future<void> _openDeveloperSite(BuildContext context) async {
    final launched = await launchUrl(
      _developerUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open link')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = AppSpacing.scale(context, AppSpacing.isCompact(context) ? 72 : 88);
    final colors = context.colors;
    final compact = AppSpacing.isCompact(context);
    final topGap = compact ? 16.0 : 32.0;
    final sectionGap = compact ? 20.0 : 40.0;

    return AppScaffold(
      showThemeBar: true,
      body: ResponsiveBody(
        padding: AppSpacing.pageInsets(context, top: topGap, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.scale(context, compact ? 12 : 14)),
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
            AppSpacing.gap(context, compact ? 16 : 24),
            Text(
              'Welcome to BMI Calculator',
              style: AppText.display(context),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gap(context, sectionGap),
            SecondaryButton(
              label: 'Measure your BMI',
              icon: Icons.monitor_weight_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LandingPage()),
              ),
            ),
            AppSpacing.gap(context, compact ? 10 : 12),
            SecondaryButton(
              label: 'See history',
              icon: Icons.history_rounded,
              onTap: () => openHistory(context),
            ),
            AppSpacing.gap(context, compact ? 10 : 12),
            SecondaryButton(
              label: 'About Developer',
              icon: Icons.person_outline_rounded,
              onTap: () => _openDeveloperSite(context),
            ),
          ],
        ),
      ),
    );
  }
}
