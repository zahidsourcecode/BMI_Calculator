import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/bmi_result.dart';
import 'bmi_api_service.dart';
import 'database_helper.dart';

class ResultsRepository {
  ResultsRepository._({
    DatabaseHelper? database,
    BmiApiService? api,
  })  : _database = database ?? DatabaseHelper.instance,
        _api = api ?? BmiApiService();

  static final ResultsRepository instance = ResultsRepository._();

  static const _legacyPrefsKey = 'bmi_results';
  static const _migrationKey = 'sqlite_migration_done';

  final DatabaseHelper _database;
  final BmiApiService _api;

  Future<void> initialize() async {
    await _migrateLegacySharedPreferences();
    _syncPendingToApi();
  }

  Future<void> saveResult(BMIResult result) async {
    await _database.insert(result.copyWith(synced: false));
    unawaited(_pushResultToApi(result));
  }

  Future<List<BMIResult>> getLocalResults() => _database.getAll();

  /// Tries to refresh from the API. Returns null when offline or server is down.
  Future<List<BMIResult>?> trySyncFromRemote() async {
    try {
      final remote = await _api.fetchResults();
      await _database.clear();
      await _database.insertAll(remote);
      return remote;
    } catch (_) {
      return null;
    }
  }

  Future<List<BMIResult>> getResults() async {
    final local = await getLocalResults();
    final remote = await trySyncFromRemote();
    return remote ?? local;
  }

  Future<void> deleteResult(BMIResult result) async {
    await _database.deleteById(result.id);
    unawaited(_deleteResultOnApi(result.id));
  }

  Future<void> clearResults() async {
    await _database.clear();
    unawaited(_clearResultsOnApi());
  }

  bool matches(BMIResult a, BMIResult b) {
    if (a.id.isNotEmpty && b.id.isNotEmpty && a.id == b.id) {
      return true;
    }

    return a.bmi == b.bmi &&
        a.status == b.status &&
        a.savedDate.millisecondsSinceEpoch == b.savedDate.millisecondsSinceEpoch;
  }

  Future<void> _migrateLegacySharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_migrationKey) == true) return;

    final jsonList = prefs.getStringList(_legacyPrefsKey) ?? [];
    if (jsonList.isNotEmpty) {
      final legacyResults = jsonList
          .map((json) {
            try {
              final map = jsonDecode(json) as Map<String, dynamic>;
              return BMIResult.fromMap(map);
            } catch (_) {
              return null;
            }
          })
          .whereType<BMIResult>()
          .toList();

      if (legacyResults.isNotEmpty) {
        await _database.insertAll(legacyResults);
      }

      await prefs.remove(_legacyPrefsKey);
    }

    await prefs.setBool(_migrationKey, true);
  }

  Future<void> _syncPendingToApi() async {
    final pending = await _database.getUnsynced();
    for (final result in pending) {
      final synced = await _pushResultToApi(result);
      if (!synced) break;
    }
  }

  Future<bool> _pushResultToApi(BMIResult result) async {
    try {
      await _api.createResult(result);
      await _database.markSynced(result.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _deleteResultOnApi(String id) async {
    try {
      await _api.deleteResult(id);
    } catch (_) {}
  }

  Future<void> _clearResultsOnApi() async {
    try {
      await _api.clearResults();
    } catch (_) {}
  }
}
