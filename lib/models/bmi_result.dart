class BMIResult {
  BMIResult({
    String? id,
    this.name = '',
    this.age = '',
    required this.bmi,
    required this.status,
    required this.normalWeightRange,
    required this.savedDate,
    this.height = 0,
    this.weight = 0,
    this.advice = '',
    this.bmiBmi = 0.0,
    this.profileImagePath = '',
    this.synced = false,
  }) : id = id ?? savedDate.microsecondsSinceEpoch.toString();

  final String id;
  final String name;
  final String age;
  final String bmi;
  final String status;
  final String normalWeightRange;
  final DateTime savedDate;
  final int height;
  final int weight;
  final String advice;
  final double bmiBmi;
  final String profileImagePath;
  final bool synced;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bmi': bmi,
      'status': status,
      'normalWeightRange': normalWeightRange,
      'savedDate': savedDate.toIso8601String(),
      'height': height,
      'weight': weight,
      'advice': advice,
      'bmiBmi': bmiBmi,
      'profileImagePath': profileImagePath,
      'synced': synced ? 1 : 0,
    };
  }

  factory BMIResult.fromMap(Map<String, dynamic> map) {
    final savedDate = DateTime.parse(
      map['savedDate']?.toString() ?? DateTime.now().toIso8601String(),
    );

    return BMIResult(
      id: map['id']?.toString(),
      name: map['name']?.toString() ?? '',
      age: map['age']?.toString() ?? '',
      bmi: map['bmi']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      normalWeightRange: map['normalWeightRange']?.toString() ?? '',
      savedDate: savedDate,
      height: (map['height'] as num?)?.toInt() ?? 0,
      weight: (map['weight'] as num?)?.toInt() ?? 0,
      advice: map['advice']?.toString() ?? '',
      bmiBmi: (map['bmiBmi'] as num?)?.toDouble() ?? 0.0,
      profileImagePath: map['profileImagePath']?.toString() ?? '',
      synced: map['synced'] == 1 || map['synced'] == true,
    );
  }

  BMIResult copyWith({bool? synced}) {
    return BMIResult(
      id: id,
      name: name,
      age: age,
      bmi: bmi,
      status: status,
      normalWeightRange: normalWeightRange,
      savedDate: savedDate,
      height: height,
      weight: weight,
      advice: advice,
      bmiBmi: bmiBmi,
      profileImagePath: profileImagePath,
      synced: synced ?? this.synced,
    );
  }
}
