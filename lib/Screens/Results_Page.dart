import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Services/results_storage.dart';
import '../Widgets/BMI_Gauge.dart';
import '../constants.dart';
import '../widgets/app_ui.dart';
import 'input_page.dart';

class ResultPage extends StatefulWidget {
  final String resultText;
  final String bmi;
  final String advise;
  final Color textColor;
  final int height;
  final int weight;
  final double bmiValue;
  final String normalWeightRange;
  final bool isSavedResult;
  final File? profileImage;
  final String name;

  const ResultPage({
    Key? key,
    required this.textColor,
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

  Color get _statusColor {
    if (widget.resultText == 'NORMAL') return AppColors.success;
    if (widget.resultText == 'UNDERWEIGHT') return AppColors.warning;
    return AppColors.danger;
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

    return AppScaffold(
      title: 'Your Result',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          tooltip: 'History',
          icon: const Icon(Icons.history_rounded, color: AppColors.textPrimary),
          onPressed: () => openHistory(context),
        ),
        IconButton(
          tooltip: 'Home',
          icon: const Icon(Icons.home_rounded, color: AppColors.textPrimary),
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
            if (widget.profileImage != null) ...[
              CircleAvatar(radius: 34, backgroundImage: FileImage(widget.profileImage!)),
              const SizedBox(height: 16),
            ],
            if (widget.name.isNotEmpty) ...[
              Text(
                widget.name,
                style: AppText.headline(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              widget.bmi,
              style: AppText.display(context).copyWith(
                fontSize: AppText.scale(context, 52),
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'kg / m²',
              style: AppText.body(context).copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            StatusBadge(
              label: widget.resultText,
              color: _statusColor,
              backgroundColor: AppColors.surface,
            ),
            const SizedBox(height: 36),
            BMIGaugeWidget(bmi: widget.bmiValue),
            const SizedBox(height: 24),
            AppCard(
              child: Text(
                widget.advise,
                textAlign: TextAlign.center,
                style: AppText.cardBody(context).copyWith(
                  color: AppColors.textOnCard,
                  fontSize: AppText.scale(context, 16),
                ),
              ),
            ),
            AppCard(
              child: Column(
                children: [
                  _statRow('Healthy BMI range', '18.5 – 25'),
                  _divider(),
                  _statRow('Healthy weight', widget.normalWeightRange),
                  _divider(),
                  _statRow(
                    'To reach BMI 25',
                    widget.bmiValue > 25 ? 'Lose ${_amountToLose().toStringAsFixed(1)} kg' : 'On track',
                  ),
                  _divider(),
                  _statRow('BMI Prime', (widget.bmiValue / 25).toStringAsFixed(2)),
                  _divider(),
                  _statRow('Ponderal Index', '${_ponderalIndex().toStringAsFixed(1)} kg/m³'),
                ],
              ),
            ),
            PrimaryButton(
              label: _resultSaved ? 'Saved to history' : 'Save to history',
              icon: _resultSaved ? Icons.check_rounded : Icons.bookmark_add_outlined,
              enabled: !_resultSaved,
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary,
              borderColor: AppColors.textPrimary,
              onTap: _saveResult,
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Calculate again',
              icon: Icons.refresh_rounded,
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => InputPage(
                    profileImage: widget.profileImage,
                    initialName: widget.name,
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
                  color: AppColors.primary,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Saved to history',
                      style: TextStyle(
                        color: AppColors.textPrimary,
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

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(color: AppColors.border.withValues(alpha: 0.5), height: 1),
      );

  Widget _statRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppText.cardBody(context))),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textOnCard,
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

  double _ponderalIndex() {
    final h = widget.height / 100;
    return widget.weight / (h * h * h);
  }

  Future<void> _saveResult() async {
    await ResultsStorage.saveResult(
      BMIResult(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: widget.name,
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
