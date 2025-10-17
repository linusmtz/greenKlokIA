import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const baseUrl = 'http://143.47.110.219:8080/api/users';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final user = data['user'];

      if (user != null) {
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'user', value: jsonEncode(user));
      }

      return {'ok': true, 'message': data['message']};
    } else {
      final body = jsonDecode(res.body);
      return {
        'ok': false,
        'msg': body['error'] ?? 'Error al iniciar sesión',
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return {'ok': true, 'message': data['message']};
    } else {
      final body = jsonDecode(res.body);
      return {
        'ok': false,
        'msg': body['error'] ?? body['message'] ?? 'Error al registrar usuario',
      };
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userData = await _storage.read(key: 'user');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }
}
