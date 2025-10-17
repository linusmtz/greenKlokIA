import 'package:flutter/material.dart';
import 'package:green_klok_ia/routes/app_routes.dart';

/// Página de acceso inicial.
///
/// Muestra el logo, una breve descripción y dos acciones principales:
/// - "Acceso": navega a la pantalla de inicio de sesión.
/// - "Inscribirse": navega a la pantalla de registro.
///
/// Esta clase es un `StatelessWidget` porque no mantiene estado local.
class AccessPage extends StatelessWidget {
  const AccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color de fondo de la pantalla
      backgroundColor: Colors.white,
      // SafeArea evita que el contenido quede debajo de barras del sistema (notch, status bar)
      body: SafeArea(
        child: Center(
          child: Padding(
            // Espacio horizontal para separar el contenido de los bordes de la pantalla
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              // Centrar verticalmente el contenido
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de la aplicación cargado desde assets
                const Image(
                  image: AssetImage('assets/images/logo.png'),
                  width: 150,
                ),
                const SizedBox(height: 20),
                // Mensaje descriptivo corto. Se usa TextAlign.center para centrar el texto.
                const Text(
                  'Optimiza el control de tu invernadero inteligente con IA y monitoreo en tiempo real.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                // Botón principal para ir a la pantalla de login
                SizedBox(
                  width: double.infinity, // Hace que el botón ocupe todo el ancho disponible
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32), // Verde corporativo
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navegar a la ruta de login usando el enrutador nombrado
                      Navigator.pushNamed(
                        context,
                        AppRoutes.login,
                      );
                    },
                    child: const Text('Acceso', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),

                // Botón secundario para registrarse
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navegar a la ruta de registro
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text('Inscribirse', style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32))),
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
