import 'package:flutter/material.dart';
import 'package:green_klok_ia/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:green_klok_ia/routes/app_routes.dart';

/// Pantalla de inicio de sesión.
///
/// Contiene campos para correo/usuario y contraseña, validación básica,
/// y la lógica de inicio de sesión que utiliza `AuthService`.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para los campos de entrada
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Controla la visibilidad del texto en el campo de contraseña
  bool _obscureText = true;

  // Ejemplo de almacenamiento seguro; puede usarse para guardar tokens
  final storage = const FlutterSecureStorage();

  /// Intenta autenticar al usuario usando `AuthService`.
  ///
  /// Valida que los campos no estén vacíos. Si la autenticación es
  /// exitosa, navega al dashboard y limpia la pila de navegación. Si
  /// falla, muestra un `SnackBar` con el mensaje de error.
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    try {
      final authService = AuthService();
      final result = await authService.login(email, password);

      if (result['ok']) {
        // Login correcto: puedes almacenar tokens en `storage` si lo
        // requieres. Aquí sólo se obtiene el usuario y se navega.
        print('✅ Login exitoso');
        final user = await authService.getUser();
        print('👤 Usuario cargado: $user');

        if (!mounted) return;

        // Reemplaza la pila de navegación para evitar volver a la
        // pantalla de login al presionar atrás.
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      } else {
        // Mostrar mensaje de error devuelto por el servicio
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['msg'] ?? 'Error al iniciar sesión')),
        );
      }
    } catch (e) {
      // Manejo genérico de errores (por ejemplo: problemas de red)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores locales para la UI
    final green = const Color(0xFF2E7D32);
    final lightGreen = const Color(0xFFDFFFD8);

    return WillPopScope(
      // Evita que el usuario salga de la app con el botón atrás en esta
      // pantalla (comportamiento intencional para el flujo de autenticación)
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono invisible para mantener espaciado consistente con
                // otras pantallas que usan un botón de retroceso.
                IconButton(
                  onPressed: () {}, // ya no hace pop
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.transparent),
                ),
                const SizedBox(height: 10),

                // Saludo principal
                Center(
                  child: Text(
                    '¡Hola!',
                    style: TextStyle(
                      color: green,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Campo para correo o teléfono
                const Text(
                  'Correo electrónico o número de móvil',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'example@example.com',
                    filled: true,
                    fillColor: lightGreen,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: green, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Campo de contraseña con opción para mostrar/ocultar texto
                const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: lightGreen,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: green,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: green),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: green, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Enlace a la pantalla de 'olvidé mi contraseña'
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: Text(
                      'Olvidar Contraseña',
                      style: TextStyle(color: green, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Botón de inicio de sesión
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Acceso',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Enlace para registrarse
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: RichText(
                      text: TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
