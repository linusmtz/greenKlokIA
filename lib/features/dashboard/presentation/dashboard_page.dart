import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:green_klok_ia/routes/app_routes.dart';

/// DashboardPage es la pantalla principal que se muestra después de un
/// inicio de sesión exitoso. Proporciona una vista general del estado del
/// sistema (Riego, Clima, Alertas, Salud), un drawer con accesos a perfil y
/// configuración, y una barra de navegación inferior para cambiar entre
/// vistas de datos.
///
/// Responsabilidades:
/// - Cargar y mostrar el nombre y correo del usuario desde el almacenamiento seguro.
/// - Mostrar un conjunto de tarjetas de estado que resumen áreas importantes.
/// - Proveer navegación (drawer y barra inferior) y la funcionalidad de cerrar sesión.
class DashboardPage extends StatefulWidget {
  /// Crea una [DashboardPage]. El widget es stateful porque carga datos
  /// asíncronos (información del usuario) y gestiona el índice seleccionado
  /// de la barra de navegación inferior.
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  /// Índice actualmente seleccionado en la barra de navegación inferior.
  /// Controla el item resaltado y puede usarse para cambiar el contenido
  /// si la página se expande para mostrar pantallas por pestaña.
  int _selectedIndex = 0;

  /// Color de fondo principal para la página del dashboard (beige suave).
  final Color beige = const Color(0xFFFFF8E1);

  /// Color verde de acento usado en el encabezado del drawer y en el item
  /// seleccionado de la navegación.
  final Color green = const Color(0xFF2E7D32);

  /// Instancia de almacenamiento seguro usada para leer y borrar datos de
  /// autenticación/usuario guardados.
  final _storage = const FlutterSecureStorage();

  /// Nombre del usuario cargado para mostrar. Es nulo mientras se carga.
  String? userName;

  /// Correo del usuario cargado. Es nulo mientras se carga.
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  /// Carga la información del usuario desde el almacenamiento seguro.
  ///
  /// Forma esperada: una cadena JSON guardada bajo la clave 'user' que
  /// contenga al menos los campos `name` y `email`. Si falta el valor o no
  /// se puede parsear, la interfaz mostrará valores por defecto sin romper
  /// la funcionalidad.
  Future<void> _loadUser() async {
    final userData = await _storage.read(key: 'user');

    if (userData != null) {
      final user = jsonDecode(userData);
      setState(() {
        // Usar valores por defecto cuando no exista un campo.
        userName = user['name'] ?? 'Usuario';
        userEmail = user['email'] ?? '';
      });
    }
  }

  /// Manejador llamado cuando se toca un item de la navegación inferior.
  /// Actualiza `_selectedIndex`. Actualmente solo cambia el estado
  /// seleccionado; se puede extender para navegar o cambiar contenido.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Realiza el cierre de sesión borrando tokens y la información del
  /// usuario en el almacenamiento seguro, y navega de vuelta a la ruta de
  /// login limpiando la pila de navegación.
  Future<void> _logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');

    if (!mounted) return;

    // Elimina todas las rutas y va a la pantalla de login.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,

      appBar: AppBar(
  // No queremos el botón 'atrás' automático en esta página.
        automaticallyImplyLeading: false,
        backgroundColor: beige,
        elevation: 0,
        title: Text(
          // Muestra el nombre del usuario cuando esté cargado, de lo
          // contrario muestra un marcador de carga.
          'Bienvenido, ${userName ?? "Cargando..."}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
          // El botón de ícono abre el end drawer (drawer en el lado derecho).
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

      // --- Drawer lateral ---
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // El encabezado del drawer muestra el logo, nombre y correo del usuario.
            DrawerHeader(
              decoration: BoxDecoration(color: green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName ?? 'Cargando...',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    userEmail ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Acción Perfil (placeholder)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad próximamente')),
                );
              },
            ),

            // Acción Configuración (placeholder)
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuraciones próximamente')),
                );
              },
            ),

            const Divider(),

            // Acción Cerrar sesión: borra credenciales y regresa al login.
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),

      // ---- CONTENIDO PRINCIPAL ----
      body: SingleChildScrollView(
  // El padding de la página mantiene el contenido alejado de los bordes de pantalla.
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de resumen / estado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.build, color: Colors.red, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Estatus general',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Acciones necesarias requieren tu atención',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid de tarjetas resumen (2 columnas). Cada tarjeta se crea
            // usando el helper `_buildCard` que recibe título, subtítulo,
            // color e ícono.
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildCard('Riego', 'Próximo en: 2 días', const Color(0xFFBBDEFB), Icons.water_drop),
                _buildCard('Clima', 'Calidad ambiental:\nAceptable', const Color(0xFFFFF59D), Icons.wb_sunny_outlined),
                _buildCard('Alertas', 'Acciones necesarias:\n3 alarmas activas', const Color(0xFFFFCC80), Icons.warning_amber_outlined),
                _buildCard('Salud', 'Estado actual:\nExcelente', const Color(0xFFC8E6C9), Icons.health_and_safety_outlined),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: green,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menú'),
          BottomNavigationBarItem(icon: Icon(Icons.thermostat), label: 'Temperatura'),
          BottomNavigationBarItem(icon: Icon(Icons.water), label: 'Humedad'),
          BottomNavigationBarItem(icon: Icon(Icons.light_mode), label: 'Luz'),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54, size: 26),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(color: Colors.black87, fontSize: 13)),
        ],
      ),
    );
  }
}
