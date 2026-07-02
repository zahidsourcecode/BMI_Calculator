import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Services/results_storage.dart';
import '../Widgets/BMI_Gauge.dart';
import '../constants.dart';
import '../Widgets/app_ui.dart';
import 'input_page.dart';

class ResultPage extends StatefulWidget {
  final String resultText;
  final String bmi;
  final String advise;
  final int height;
  final int weight;
  final double bmiValue;
  final String normalWeightRange;
  final bool isSavedResult;
  final File? profileImage;
  final String name;
  final String age;

  const ResultPage({
    Key? key,
    required this.resultText,
    required this.bmi,
    required this.advise,
    required this.height,
    required this.weight,
    required this.bmiValue,
    required this.normalWeightRange,
    this.isSavedResult = false,
    this.profileImage,
    this.name = '',
    this.age = '',
  }) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  late bool _resultSaved = widget.isSavedResult;
  bool _showSavedMessage = false;
  late final AnimationController _popupShakeController;
  late final Animation<double> _popupShakeAnimation;

  @override
  void initState() {
    super.initState();
    _popupShakeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _popupShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _popupShakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _popupShakeController.dispose();
    super.dispose();
  }

  Color _statusColor(BuildContext context) {
    final colors = context.colors;
    if (widget.resultText == 'NORMAL') return colors.success;
    if (widget.resultText == 'UNDERWEIGHT') return colors.warning;
    return colors.danger;
  }

  String get _statusLabel {
    final text = widget.resultText;
    if (text.isEmpty) return text;
    return text[0] + text.substring(1).toLowerCase();
  }

  void _showSavedToHistoryPopup() {
    HapticFeedback.lightImpact();
    setState(() => _showSavedMessage = true);
    _popupShakeController.forward(from: 0);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSavedMessage = false);
        _popupShakeController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.page(context);
    final colors = context.colors;

    return AppScaffold(
      title: 'Your Result',
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          tooltip: 'History',
          icon: Icon(Icons.history_rounded, color: colors.textPrimary),
          onPressed: () => openHistory(context),
        ),
        IconButton(
          tooltip: 'Home',
          icon: Icon(Icons.home_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        const SizedBox(width: 4),
      ],
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, 4, padding, padding),
        child: Column(
          children: [
            if (widget.name.isNotEmpty) ...[
              Text(
                widget.name,
                style: AppText.headline(context),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gap(context, 8),
            ],
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    StatusBadge(
                      label: _statusLabel,
                      color: _statusColor(context),
                      backgroundColor: colors.badgeSurface,
                      fontSize: 15,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.scale(context, 16),
                        vertical: AppSpacing.scale(context, 8),
                      ),
                    ),
                    AppSpacing.gapH(context, 12),
                    Text(
                      widget.bmi,
                      style: AppText.display(context).copyWith(
                        fontSize: AppText.scale(context, 36),
                        color: colors.textPrimary,
                      ),
                    ),
                    AppSpacing.gapH(context, 6),
                    Text(
                      'kg / m²',
                      style: AppText.body(context).copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.gap(context, 12),
            BMIGaugeWidget(bmi: widget.bmiValue),
            AppCard(
              child: Text(
                widget.advise,
                textAlign: TextAlign.center,
                style: AppText.cardBody(context).copyWith(
                  color: colors.textOnCard,
                  fontSize: AppText.scale(context, 16),
                ),
              ),
            ),
            AppCard(
              child: Column(
                children: [
                  _statRow('Healthy BMI range', '18.5 – 25'),
                  _divider(context),
                  _statRow('Healthy weight', widget.normalWeightRange),
                  _divider(context),
                  _statRow(
                    'To reach BMI 25',
                    widget.bmiValue > 25 ? 'Lose ${_amountToLose().toStringAsFixed(1)} kg' : 'On track',
                  ),
                  _divider(context),
                  _statRow('BMI Prime', (widget.bmiValue / 25).toStringAsFixed(2)),
                ],
              ),
            ),
            PrimaryButton(
              label: _resultSaved ? 'Saved to history' : 'Save to history',
              icon: _resultSaved ? Icons.check_rounded : Icons.bookmark_add_outlined,
              enabled: !_resultSaved,
              onTap: _saveResult,
            ),
            AppSpacing.gap(context, 12),
            SecondaryButton(
              label: 'Calculate again',
              icon: Icons.refresh_rounded,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => InputPage(
                    profileImage: widget.profileImage,
                    initialName: widget.name,
                    initialAge: widget.age,
                  ),
                ),
                (route) => route.isFirst,
              ),
            ),
          ],
        ),
      ),
          if (_showSavedMessage)
            Positioned(
              top: 0,
              left: padding,
              right: padding,
              child: AnimatedBuilder(
                animation: _popupShakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_popupShakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  color: colors.button,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.textPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Saved to history',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppText.scale(context, 15),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.scale(context, 12)),
        child: Divider(color: context.colors.border.withValues(alpha: 0.5), height: 1),
      );

  Widget _statRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppText.cardBody(context))),
        Text(
          value,
          style: TextStyle(
            color: context.colors.textOnCard,
            fontWeight: FontWeight.w600,
            fontSize: AppText.scale(context, 14),
          ),
        ),
      ],
    );
  }

  double _amountToLose() {
    final ideal = 25.0 * (widget.height / 100) * (widget.height / 100);
    final diff = widget.weight - ideal;
    return diff > 0 ? diff : 0;
  }

  Future<void> _saveResult() async {
    await ResultsStorage.saveResult(
      BMIResult(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: widget.name,
        age: widget.age,
        bmi: widget.bmi,
        status: widget.resultText,
        normalWeightRange: widget.normalWeightRange,
        savedDate: DateTime.now(),
        height: widget.height,
        weight: widget.weight,
        advice: widget.advise,
        bmiBmi: widget.bmiValue,
        profileImagePath: widget.profileImage?.path ?? '',
      ),
    );

    if (!mounted) return;
    setState(() => _resultSaved = true);
    _showSavedToHistoryPopup();
  }
}
