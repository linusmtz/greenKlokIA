import 'package:flutter/material.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/auth/presentation/access_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';


class AppRoutes {
  /// Ruta de la pantalla splash (pantalla inicial).
  static const splash = '/';

  /// Ruta para selección de acceso (p. ej. elegir entre login/registro).
  static const access = '/access';

  /// Ruta de inicio de sesión.
  static const login = '/login';

  /// Ruta de registro de usuario.
  static const register = '/register';

  /// Ruta para restablecer contraseña (normalmente con token o código).
  static const resetPassword = '/reset-password';

  /// Ruta para el flujo de 'olvidé mi contraseña'.
  static const forgotPassword = '/forgot-password';

  /// Ruta principal del dashboard mostrada tras el login.
  static const dashboard = '/dashboard'; 

  /// Mapa de rutas usadas por la aplicación. La clave es el nombre de la
  /// ruta y el valor es un `WidgetBuilder` que crea la pantalla
  /// correspondiente. Usar este mapa en `MaterialApp(routes: AppRoutes.routes)`.
  static Map<String, WidgetBuilder> get routes => {
        // Pantalla inicial
        splash: (_) => const SplashPage(),

        // Pantalla para elegir acceso
        access: (_) => const AccessPage(),

        // Flujo de autenticación
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        resetPassword: (_) => const ResetPasswordPage(),
        forgotPassword: (_) => const ForgotPasswordPage(),

        // Dashboard principal
        dashboard: (_) => const DashboardPage(),
      };
}