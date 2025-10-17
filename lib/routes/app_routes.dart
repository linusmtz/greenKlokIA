import 'package:flutter/material.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/auth/presentation/access_page.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/auth/presentation/forgot_password_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';


class AppRoutes {
  static const splash = '/';
  static const access = '/access';
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard'; 

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        access: (_) => const AccessPage(),
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        resetPassword: (_) => const ResetPasswordPage(),
        forgotPassword: (_) => const ForgotPasswordPage(),
        dashboard: (_) => const DashboardPage(),
      };
}