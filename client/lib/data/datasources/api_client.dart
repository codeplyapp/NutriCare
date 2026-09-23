import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutricare/core/constants/api_constants.dart';
import 'package:nutricare/data/datasources/local_datasource.dart';

class ApiClient {
  final LocalDataSource _localDataSource;

  ApiClient({LocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? LocalDataSource();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _localDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Bypass-Tunnel-Reminder': 'true',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(endpoint), headers: headers);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final errorMsg = body is Map && body.containsKey('detail')
          ? body['detail']
          : 'Terjadi kesalahan pada server (Kode: ${response.statusCode})';
      throw Exception(errorMsg);
    }
  }
}
