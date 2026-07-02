import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/bmi_result.dart';

class BmiApiException implements Exception {
  BmiApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class BmiApiService {
  BmiApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _fetchTimeout = Duration(seconds: 2);
  static const _writeTimeout = Duration(seconds: 3);

  Future<List<BMIResult>> fetchResults() async {
    final response = await _client
        .get(ApiConfig.uri('/api/results'))
        .timeout(_fetchTimeout);

    if (response.statusCode != 200) {
      throw BmiApiException('Failed to load results', statusCode: response.statusCode);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw BmiApiException('Unexpected response format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map((item) => BMIResult.fromMap(item).copyWith(synced: true))
        .toList();
  }

  Future<void> createResult(BMIResult result) async {
    final response = await _client
        .post(
          ApiConfig.uri('/api/results'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(result.toMap()),
        )
        .timeout(_writeTimeout);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw BmiApiException('Failed to save result', statusCode: response.statusCode);
    }
  }

  Future<void> deleteResult(String id) async {
    final response = await _client
        .delete(ApiConfig.uri('/api/results/$id'))
        .timeout(_writeTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw BmiApiException('Failed to delete result', statusCode: response.statusCode);
    }
  }

  Future<void> clearResults() async {
    final response = await _client
        .delete(ApiConfig.uri('/api/results'))
        .timeout(_writeTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw BmiApiException('Failed to clear results', statusCode: response.statusCode);
    }
  }
}
