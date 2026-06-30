import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/app_ui.dart';
import 'landing_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.page(context);

    return AppScaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(padding, 8, padding, padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset('assets/icon/appIcon.png', width: 72, height: 72),
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'See history',
              icon: Icons.history_rounded,
              onTap: () => openHistory(context),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
