import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

import '../config/database_config.dart';
import '../models/bmi_result.dart';

class DatabaseHelper {
  DatabaseHelper._({Future<String> Function()? pathResolver})
      : _pathResolver = pathResolver ?? DatabaseConfig.resolvePath;

  static final DatabaseHelper _default = DatabaseHelper._();
  static DatabaseHelper? _testOverride;

  static DatabaseHelper get instance => _testOverride ?? _default;

  @visibleForTesting
  static void setTestInstance(DatabaseHelper? helper) {
    _testOverride = helper;
  }

  @visibleForTesting
  factory DatabaseHelper.forPath(Future<String> Function() resolver) {
    return DatabaseHelper._(pathResolver: resolver);
  }

  static const _table = 'bmi_results';

  final Future<String> Function() _pathResolver;
  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final dbPath = await _pathResolver();
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            age TEXT NOT NULL,
            bmi TEXT NOT NULL,
            status TEXT NOT NULL,
            normal_weight_range TEXT NOT NULL,
            saved_date TEXT NOT NULL,
            height INTEGER NOT NULL,
            weight INTEGER NOT NULL,
            advice TEXT NOT NULL,
            bmi_value REAL NOT NULL,
            profile_image_path TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );

    _database = db;
    return db;
  }

  Future<void> insert(BMIResult result) async {
    final db = await database;
    await db.insert(
      _table,
      _toRow(result),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAll(List<BMIResult> results) async {
    final db = await database;
    final batch = db.batch();
    for (final result in results) {
      batch.insert(
        _table,
        _toRow(result),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<BMIResult>> getAll() async {
    final db = await database;
    final rows = await db.query(
      _table,
      orderBy: 'saved_date ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<void> deleteById(String id) async {
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete(_table);
  }

  Future<void> markSynced(String id) async {
    final db = await database;
    await db.update(
      _table,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BMIResult>> getUnsynced() async {
    final db = await database;
    final rows = await db.query(
      _table,
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'saved_date ASC',
    );
    return rows.map(_fromRow).toList();
  }

  Map<String, Object?> _toRow(BMIResult result) {
    return {
      'id': result.id,
      'name': result.name,
      'age': result.age,
      'bmi': result.bmi,
      'status': result.status,
      'normal_weight_range': result.normalWeightRange,
      'saved_date': result.savedDate.toIso8601String(),
      'height': result.height,
      'weight': result.weight,
      'advice': result.advice,
      'bmi_value': result.bmiBmi,
      'profile_image_path': result.profileImagePath,
      'synced': result.synced ? 1 : 0,
    };
  }

  BMIResult _fromRow(Map<String, Object?> row) {
    return BMIResult(
      id: row['id'] as String,
      name: row['name'] as String? ?? '',
      age: row['age'] as String? ?? '',
      bmi: row['bmi'] as String? ?? '',
      status: row['status'] as String? ?? '',
      normalWeightRange: row['normal_weight_range'] as String? ?? '',
      savedDate: DateTime.parse(row['saved_date'] as String),
      height: row['height'] as int? ?? 0,
      weight: row['weight'] as int? ?? 0,
      advice: row['advice'] as String? ?? '',
      bmiBmi: (row['bmi_value'] as num?)?.toDouble() ?? 0.0,
      profileImagePath: row['profile_image_path'] as String? ?? '',
      synced: row['synced'] == 1,
    );
  }
}
