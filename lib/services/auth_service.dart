import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio responsable de las operaciones de autenticación y gestión
/// básica del usuario en almacenamiento seguro.
///
/// Este servicio encapsula las llamadas HTTP al backend (login y
/// registro) y maneja la persistencia de token/usuario usando
/// `FlutterSecureStorage`.
class AuthService {
  /// URL base del API para usuarios. Ajustar según el entorno (dev/prod).
  static const baseUrl = 'http://143.47.110.219:8080/api/users';

  /// Instancia de almacenamiento seguro para guardar token y datos de usuario.
  final _storage = const FlutterSecureStorage();

  /// Realiza la petición de inicio de sesión con [email] y [password].
  ///
  /// Si la respuesta es correcta (status 200) guarda el `token` y el
  /// `user` en almacenamiento seguro y retorna un mapa con `ok: true`
  /// y un `message`. En caso de error retorna `ok: false` y `msg` con el
  /// mensaje de error.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final user = data['user'];

      // Si viene información de usuario, la persistimos junto al token.
      if (user != null) {
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'user', value: jsonEncode(user));
      }

      return {'ok': true, 'message': data['message']};
    } else {
      final body = jsonDecode(res.body);
      return {
        'ok': false,
        // Usar el error devuelto por el backend cuando esté disponible.
        'msg': body['error'] ?? 'Error al iniciar sesión',
      };
    }
  }

  /// Registra un nuevo usuario con los datos proporcionados. Retorna un
  /// mapa con `ok: true` y `message` en caso de éxito (201) o `ok: false`
  /// y `msg` con el motivo del fallo.
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
        // Intentar extraer un mensaje claro del backend o usar un fallback.
        'msg': body['error'] ?? body['message'] ?? 'Error al registrar usuario',
      };
    }
  }

  /// Cierra la sesión eliminando todos los datos guardados en almacenamiento seguro.
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// Lee y retorna el token almacenado (si existe).
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  /// Recupera los datos del usuario almacenados y los decodifica como mapa.
  /// Retorna `null` si no hay datos.
  Future<Map<String, dynamic>?> getUser() async {
    final userData = await _storage.read(key: 'user');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }
}
