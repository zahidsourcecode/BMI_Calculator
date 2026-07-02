import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../calculator_brain.dart';
import '../constants.dart';
import '../Widgets/app_ui.dart';
import 'Results_Page.dart';
import 'landing_page.dart';

class InputPage extends StatefulWidget {
  const InputPage({
    Key? key,
    this.profileImage,
    this.initialName,
    this.initialAge,
  }) : super(key: key);

  final File? profileImage;
  final String? initialName;
  final String? initialAge;

  @override
  State<InputPage> createState() => _InputPageState();
}

enum Gender { male, female }

class _InputPageState extends State<InputPage> {
  int feet = 5;
  int inches = 10;
  int weight = 70;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialAge != null && widget.initialAge!.isNotEmpty) {
      _ageController.text = widget.initialAge!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculate() {
    final heightInCm = (feet * 30.48 + inches * 2.54).round();
    final calc = Calculate(height: heightInCm, weight: weight);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          bmi: calc.result(),
          resultText: calc.getText(),
          advise: calc.getAdvise(),
          height: heightInCm,
          weight: weight,
          bmiValue: calc.getBMI(),
          normalWeightRange: calc.getNormalWeightRange(),
          profileImage: widget.profileImage,
          name: _nameController.text.trim(),
          age: _ageController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.page(context);
    final fieldRadius = AppSpacing.radius(context, 12);
    final fieldPadding = EdgeInsets.symmetric(
      horizontal: AppSpacing.scale(context, 16),
      vertical: AppSpacing.scale(context, 14),
    );

    return AppScaffold(
      title: 'Measurements',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
        ),
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
        AppSpacing.gapH(context, 4),
      ],
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, 4, padding, padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.profileImage != null) ...[
              Center(
                child: CircleAvatar(
                  radius: AppSpacing.scale(context, 36),
                  backgroundImage: FileImage(widget.profileImage!),
                ),
              ),
              AppSpacing.gap(context, 16),
            ],
            _optionalField(
              controller: _nameController,
              hint: 'Enter your name (optional)',
              textCapitalization: TextCapitalization.words,
              fieldRadius: fieldRadius,
              fieldPadding: fieldPadding,
            ),
            _optionalField(
              controller: _ageController,
              hint: 'Enter your age (optional)',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              fieldRadius: fieldRadius,
              fieldPadding: fieldPadding,
            ),
            AppCard(
              child: Column(
                children: [
                  Text('HEIGHT', style: AppText.cardLabel(context)),
                  AppSpacing.gap(context, 8),
                  FittedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$feet', style: AppText.cardValue(context)),
                        Text(' ft ', style: AppText.cardBody(context)),
                        Text('$inches', style: AppText.cardValue(context)),
                        Text(' in', style: AppText.cardBody(context)),
                      ],
                    ),
                  ),
                  AppSpacing.gap(context, 8),
                  _slider('Feet', feet.toDouble(), 4, 7, 3, (v) => setState(() => feet = v.round())),
                  _slider('Inches', inches.toDouble(), 0, 11, 11, (v) => setState(() => inches = v.round())),
                ],
              ),
            ),
            AppCard(
              child: Column(
                children: [
                  Text('Weight (KG)', style: AppText.cardLabel(context)),
                  AppSpacing.gap(context, 12),
                  StepperControl(
                    value: weight,
                    minValue: 1,
                    onDecrement: () => setState(() => weight--),
                    onIncrement: () => setState(() => weight++),
                  ),
                ],
              ),
            ),
            AppSpacing.gap(context, 8),
            PrimaryButton(
              label: 'Calculate BMI',
              icon: Icons.calculate_outlined,
              borderColor: AppColors.textPrimary,
              onTap: _calculate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionalField({
    required TextEditingController controller,
    required String hint,
    required double fieldRadius,
    required EdgeInsets fieldPadding,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return AppCard(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        style: AppText.cardBody(context).copyWith(
          color: AppColors.textOnCard,
          fontSize: AppText.scale(context, 16),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.cardBody(context),
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding: fieldPadding,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(fieldRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(fieldRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(fieldRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.scale(context, 8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: AppSpacing.scale(context, 52),
            child: Text(label, style: AppText.cardLabel(context)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
