import 'dart:io';

import 'package:flutter/material.dart';
import '../Components/Action_Button.dart';
import '../Services/results_storage.dart';
import '../Widgets/BMI_Gauge.dart';
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

  const ResultPage({
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
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late bool _resultSaved = widget.isSavedResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A2F51),
      appBar: AppBar(
        title: Center(
          child: Text('BMI CALCULATOR'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(15.0),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BMI = ${widget.bmi} kg/m²',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '(${widget.resultText})',
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: BMIGaugeWidget(bmi: widget.bmiValue),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Healthy BMI range:',
                      '18.5 - 25 kg/m²',
                    ),
                    SizedBox(height: 10.0),
                    _buildInfoRow(
                      'Healthy weight for the height:',
                      widget.normalWeightRange,
                    ),
                    SizedBox(height: 10.0),
                    _buildInfoRow(
                      'Lose ${_amountToLose().toStringAsFixed(1)} kg',
                      'to reach a BMI of 25 kg/m².',
                    ),
                    SizedBox(height: 10.0),
                    _buildInfoRow(
                      'BMI Prime:',
                      (widget.bmiValue / 25).toStringAsFixed(2),
                    ),
                    SizedBox(height: 10.0),
                    _buildInfoRow(
                      'Ponderal Index:',
                      '${_ponderalIndex().toStringAsFixed(1)} kg/m³',
                    ),
                    SizedBox(height: 15.0),
                    Center(
                      child: ActionButton(
                        label: 'SAVE RESULT',
                        width: 200.0,
                        height: 56.0,
                        enabled: !_resultSaved,
                        onTap: _saveResult,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: ActionButton(
              label: 'RE-CALCULATE',
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputPage(
                      profileImage: widget.profileImage,
                    ),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF8D8E98),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  double _amountToLose() {
    final idealWeightKg =
        25.0 * (widget.height / 100) * (widget.height / 100);
    final diffKg = widget.weight - idealWeightKg;

    return diffKg > 0 ? diffKg : 0;
  }

  double _ponderalIndex() {
    final heightInMeters = widget.height / 100;
    return widget.weight / (heightInMeters * heightInMeters * heightInMeters);
  }

  void _saveResult() async {
    final result = BMIResult(
      bmi: widget.bmi,
      status: widget.resultText,
      normalWeightRange: widget.normalWeightRange,
      savedDate: DateTime.now(),
      height: widget.height,
      weight: widget.weight,
      advice: widget.advise,
      bmiBmi: widget.bmiValue,
      profileImagePath: widget.profileImage?.path ?? '',
    );

    await ResultsStorage.saveResult(result);

    if (mounted) {
      setState(() {
        _resultSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Result saved successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF24D876),
        ),
      );
    }
  }
}
