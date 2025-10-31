import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SensorService {
  static const baseUrl = 'http://143.47.110.219:8080/api/sensors';
  final _storage = const FlutterSecureStorage();

  // 🔹 Método base para solicitudes GET simples
  Future<Map<String, dynamic>> _fetch(String endpoint) async {
    final token = await _storage.read(key: 'token');
    final res = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(
        'Error al obtener datos de sensores (${res.statusCode}): ${res.body}',
      );
    }
  }

  // 🔹 Obtener valor más reciente por tipo
  Future<Map<String, dynamic>> getSensorType(String greenhouseId, String type) =>
      _fetch('$greenhouseId/$type');

  Future<Map<String, dynamic>> getTemperature(String greenhouseId) =>
      getSensorType(greenhouseId, 'temperature');

  Future<Map<String, dynamic>> getHumidityAir(String greenhouseId) =>
      getSensorType(greenhouseId, 'humidity_air');

  Future<Map<String, dynamic>> getHumiditySoil(String greenhouseId) =>
      getSensorType(greenhouseId, 'humidity_soil');

  Future<Map<String, dynamic>> getLight(String greenhouseId) =>
      getSensorType(greenhouseId, 'light');

  Future<Map<String, dynamic>> getPh(String greenhouseId) =>
      getSensorType(greenhouseId, 'ph');

  // 🔹 Obtener histórico de lecturas (por tipo y rango)
  Future<Map<String, dynamic>> getSensorHistory(
    String greenhouseId, {
    required String type,
    String range = '1d',
  }) async {
    final token = await _storage.read(key: 'token');
    final uri = Uri.parse(
      '$baseUrl/$greenhouseId/history?type=$type&range=$range',
    );

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception(
        'Error al obtener historial (${res.statusCode}): ${res.body}',
      );
    }
  }
}
