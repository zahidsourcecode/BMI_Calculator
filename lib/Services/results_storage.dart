import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BMIResult {
  final String id;
  final String name;
  final String bmi;
  final String status;
  final String normalWeightRange;
  final DateTime savedDate;
  final int height;
  final int weight;
  final String advice;
  final double bmiBmi;
  final String profileImagePath;

  BMIResult({
    String? id,
    this.name = '',
    required this.bmi,
    required this.status,
    required this.normalWeightRange,
    required this.savedDate,
    this.height = 0,
    this.weight = 0,
    this.advice = '',
    this.bmiBmi = 0.0,
    this.profileImagePath = '',
  }) : id = id ?? savedDate.microsecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bmi': bmi,
      'status': status,
      'normalWeightRange': normalWeightRange,
      'savedDate': savedDate.toIso8601String(),
      'height': height,
      'weight': weight,
      'advice': advice,
      'bmiBmi': bmiBmi,
      'profileImagePath': profileImagePath,
    };
  }

  factory BMIResult.fromMap(Map<String, dynamic> map) {
    final savedDate = DateTime.parse(
      map['savedDate'] ?? DateTime.now().toIso8601String(),
    );

    return BMIResult(
      id: map['id'] as String?,
      name: map['name']?.toString() ?? '',
      bmi: map['bmi'] ?? '',
      status: map['status'] ?? '',
      normalWeightRange: map['normalWeightRange'] ?? '',
      savedDate: savedDate,
      height: map['height'] ?? 0,
      weight: map['weight'] ?? 0,
      advice: map['advice'] ?? '',
      bmiBmi: (map['bmiBmi'] ?? 0).toDouble(),
      profileImagePath: map['profileImagePath'] ?? '',
    );
  }
}

class ResultsStorage {
  static const String _key = 'bmi_results';

  static Future<void> saveResult(BMIResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await getResults();
    results.add(result);

    final jsonList = results.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<BMIResult>> getResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList
        .map((json) {
          try {
            final map = jsonDecode(json) as Map<String, dynamic>;
            return BMIResult.fromMap(map);
          } catch (e) {
            return null;
          }
        })
        .whereType<BMIResult>()
        .toList();
  }

  static Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> deleteResult(BMIResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await getResults();

    final index = results.indexWhere((r) => _matches(r, result));
    if (index == -1) return;

    results.removeAt(index);

    final jsonList = results.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static bool matches(BMIResult a, BMIResult b) => _matches(a, b);

  static bool _matches(BMIResult a, BMIResult b) {
    if (a.id.isNotEmpty && b.id.isNotEmpty && a.id == b.id) {
      return true;
    }

    return a.bmi == b.bmi &&
        a.status == b.status &&
        a.savedDate.millisecondsSinceEpoch == b.savedDate.millisecondsSinceEpoch;
  }
}
