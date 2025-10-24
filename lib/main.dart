import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

/// Punto de entrada de la aplicación.
///
/// `main` invoca `runApp` con el widget raíz `GreenKlokIA`.
void main() {
  runApp(const GreenKlokIA());
}

/// Widget raíz de la aplicación.
///
/// Configura `MaterialApp` con título, tema, rutas iniciales y el mapa de rutas
/// definido en `AppRoutes`. Al mantener `GreenKlokIA` como un `StatelessWidget`
/// la configuración de navegación y tema permanece inmutable durante la sesión.
class GreenKlokIA extends StatelessWidget {
  const GreenKlokIA({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título de la app usado por el sistema.
      title :"GreenKlokIA",

      // Oculta la etiqueta de modo debug en la esquina.
      debugShowCheckedModeBanner: false,

      // Tema principal de la aplicación. Usamos ColorScheme generado desde
      // una semilla (seedColor) para garantizar consistencia cromática.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true
      ),

      // Rutas: la ruta inicial y el mapa de rutas centralizado en AppRoutes.
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes
    );
  }
}
 