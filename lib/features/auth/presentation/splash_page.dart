import 'package:flutter/material.dart';
import 'package:green_klok_ia/routes/app_routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Pantalla de splash que se muestra al iniciar la aplicación.
///
/// Durante unos segundos muestra el logo y verifica si existe un token
/// de sesión en el almacenamiento seguro. Si hay un token válido, navega
/// al `dashboard`; si no, redirige a la pantalla de `login`.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // Uso de almacenamiento seguro para leer un posible token de sesión
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Inicia la comprobación de sesión cuando el widget se crea
    _initAndCheckSession();
  }

  /// Inicializa tareas y comprueba si existe sesión activa.
  ///
  /// `WidgetsFlutterBinding.ensureInitialized()` se asegura de que el
  /// binding esté listo antes de realizar operaciones que lo requieran.
  /// Se simula una espera de 2 segundos para mostrar el splash.
  Future<void> _initAndCheckSession() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Future.delayed(const Duration(seconds: 2));


    final token = await _storage.read(key: 'token');

    if (!mounted) return; // Evita llamadas si el widget ya no está en árbol

    if (token != null && token.isNotEmpty) {
      // Si hay token, vamos al dashboard y limpiamos la pila de navegación
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
    } else {
      // Si no hay token, ir al login
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4CAF50),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/logo.png'),
              width: 140,
            ),
            SizedBox(height: 20),
            Text(
              'GreenKlokIA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 80),
            Text(
              'Tec Laguna',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
