import 'dart:math';
import 'package:flutter/material.dart';
import 'constants.dart';

class Calculate {
  Calculate({required this.height, required this.weight});

  final int height;
  final int weight;
  double _bmi = 0;

  String result() {
    _bmi = weight / pow(height / 100, 2);
    return _bmi.toStringAsFixed(1);
  }

  String getText() {
    if (_bmi >= 25) return 'OVERWEIGHT';
    if (_bmi >= 18.5) return 'NORMAL';
    return 'UNDERWEIGHT';
  }

  String getAdvise() {
    if (_bmi >= 25) {
      return 'You are above the healthy BMI range. Regular activity and balanced meals can help you move toward your goal.';
    }
    if (_bmi > 18.5) {
      return 'You are in a healthy BMI range. Keep up your current habits and stay active.';
    }
    return 'You are below the healthy BMI range. Consider nutrient-rich meals and consult a professional if needed.';
  }

  Color getTextColor() {
    if (_bmi >= 25) return AppColors.danger;
    if (_bmi >= 18.5) return AppColors.success;
    return AppColors.warning;
  }

  double getBMI() => _bmi;

  String getNormalWeightRange() {
    final minWeight = 18.5 * pow(height / 100, 2);
    final maxWeight = 25 * pow(height / 100, 2);
    return '${minWeight.toStringAsFixed(1)} – ${maxWeight.toStringAsFixed(1)} kg';
  }
}
