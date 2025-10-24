import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class GreenhouseService {
  static const baseUrl = 'http://143.47.110.219:8080/api/greenhouses';
  final _storage = const FlutterSecureStorage();

  /// ✅ Obtener invernaderos por usuario
  Future<List<dynamic>> getGreenhouses() async {
    final userData = await _storage.read(key: 'user');
    if (userData == null) return [];

    final user = jsonDecode(userData);
    final userId = _extractUserId(user);

    final res = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['greenhouses'] ?? [];
    } else {
      print('⚠️ Error al obtener invernaderos: ${res.body}');
      return [];
    }
  }

  /// ✅ Registrar invernadero
  Future<Map<String, dynamic>> registerGreenhouse({
    required String activationCode,
    required String greenhouseName,
  }) async {
    final userData = await _storage.read(key: 'user');
    if (userData == null) throw Exception('Usuario no encontrado');

    final user = jsonDecode(userData);
    final userId = _extractUserId(user);

    print('🧩 Enviando userId al backend: $userId');

    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'activationCode': activationCode,
        'greenhouseName': greenhouseName,
      }),
    );

    final data = jsonDecode(res.body);
    print('📦 Respuesta backend: $data');

    if (res.statusCode == 200 || res.statusCode == 201) {
      return {'ok': true, 'message': data['message']};
    } else {
      return {'ok': false, 'message': data['message'] ?? 'Error desconocido'};
    }
  }

  /// 🧠 Helper: extrae correctamente el ObjectId de cualquier formato
  String _extractUserId(Map<String, dynamic> user) {
    if (user['_id'] is Map && user['_id']['\$oid'] != null) {
      return user['_id']['\$oid'];
    } else if (user['_id'] is String) {
      return user['_id'];
    } else if (user['id'] is String) {
      return user['id'];
    } else {
      throw Exception('No se pudo extraer el userId del objeto usuario: $user');
    }
  }
}
