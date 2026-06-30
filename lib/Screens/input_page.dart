import 'dart:io';
import 'package:flutter/material.dart';
import '../calculator_brain.dart';
import '../constants.dart';
import '../widgets/app_ui.dart';
import 'Results_Page.dart';
import 'landing_page.dart';

class InputPage extends StatefulWidget {
  final Gender? preSelectedGender;
  final File? profileImage;
  final String? initialName;

  const InputPage({
    Key? key,
    this.preSelectedGender,
    this.profileImage,
    this.initialName,
  }) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

enum Gender { male, female }

class _InputPageState extends State<InputPage> {
  int feet = 5;
  int inches = 10;
  int weight = 70;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      _nameController.text = widget.initialName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          textColor: calc.getTextColor(),
          height: heightInCm,
          weight: weight,
          bmiValue: calc.getBMI(),
          normalWeightRange: calc.getNormalWeightRange(),
          profileImage: widget.profileImage,
          name: _nameController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppSpacing.page(context);

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
        const SizedBox(width: 4),
      ],
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, 4, padding, padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.profileImage != null) ...[
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: FileImage(widget.profileImage!),
                ),
              ),
              const SizedBox(height: 16),
            ],
            AppCard(
              child: TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: AppText.cardBody(context).copyWith(
                      color: AppColors.textOnCard,
                      fontSize: AppText.scale(context, 16),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name (optional)',
                      hintStyle: AppText.cardBody(context),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
            ),
            AppCard(
              child: Column(
                children: [
                  Text('HEIGHT', style: AppText.cardLabel(context)),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
                  _slider('Feet', feet.toDouble(), 4, 7, 3, (v) => setState(() => feet = v.round())),
                  _slider('Inches', inches.toDouble(), 0, 11, 11, (v) => setState(() => inches = v.round())),
                ],
              ),
            ),
            AppCard(
              child: Column(
                children: [
                  Text('Weight (KG)', style: AppText.cardLabel(context)),
                  const SizedBox(height: 12),
                  StepperControl(
                    value: weight,
                    minValue: 1,
                    onDecrement: () => setState(() => weight--),
                    onIncrement: () => setState(() => weight++),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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

  Widget _slider(String label, double value, double min, double max, int divisions, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 52,
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
