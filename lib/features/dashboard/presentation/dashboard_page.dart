import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:green_klok_ia/routes/app_routes.dart';
import 'package:green_klok_ia/services/greenhouse_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final Color beige = const Color(0xFFFFF8E1);
  final Color green = const Color(0xFF2E7D32);
  final _storage = const FlutterSecureStorage();

  String? userName;
  String? userEmail;

  // ---- Variables para los invernaderos ----
  List<dynamic> userGreenhouses = [];
  String? selectedGreenhouse;
  bool isLoadingGreenhouses = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadGreenhouses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGreenhouses(); // recarga al volver del registro
  }

  // Cargar usuario del almacenamiento seguro
  Future<void> _loadUser() async {
    final userData = await _storage.read(key: 'user');
    if (userData != null) {
      final user = jsonDecode(userData);
      setState(() {
        userName = user['name'] ?? 'Usuario';
        userEmail = user['email'] ?? '';
      });
    }
  }

  // Cargar invernaderos desde el backend
  Future<void> _loadGreenhouses() async {
    final service = GreenhouseService();
    final data = await service.getGreenhouses();
    
    setState(() {
      userGreenhouses = data;
      isLoadingGreenhouses = false;
      if (userGreenhouses.isNotEmpty) {
        selectedGreenhouse = userGreenhouses.first['name'];
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: beige,
        elevation: 0,
        title: Text(
          'Bienvenido, ${userName ?? "Cargando..."}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
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

      endDrawer: _buildDrawer(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: isLoadingGreenhouses
            ? const Center(child: CircularProgressIndicator())
            : userGreenhouses.isEmpty
                ? _buildDummyDashboard(context)
                : _buildRealDashboard(context),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---- Drawer lateral ----
  Widget _buildDrawer() {
    return Drawer(
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
    );
  }

  // ---- Dummy Dashboard (sin invernaderos) ----
  Widget _buildDummyDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Image.asset(
          'assets/images/empty_greenhouse.png',
          height: 200,
        ),
        const SizedBox(height: 20),
        const Text(
          'Aún no tienes invernaderos registrados 🌱',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          onPressed: () async {
            await Navigator.pushNamed(context, AppRoutes.registerGreenhouse);
            _loadGreenhouses();
          },
          icon: const Icon(Icons.add),
          label: const Text("Registrar nuevo invernadero"),
        ),
        const SizedBox(height: 50),
        const Text(
          'Dashboard de prueba (datos simulados):',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        _buildDummyGrid(),
      ],
    );
  }

  // ---- Dashboard real (con invernaderos existentes) ----
  Widget _buildRealDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tus invernaderos',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.registerGreenhouse);
                _loadGreenhouses(); // recargar lista después
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: const Text(
                "Nuevo",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // --- Dropdown bonito ---
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          color: const Color(0xFFF1F8E9),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedGreenhouse,
                isExpanded: true,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.black87),
                items: userGreenhouses.map<DropdownMenuItem<String>>((gh) {
                  return DropdownMenuItem<String>(
                    value: gh['name'],
                    child: Row(
                      children: [
                        const Icon(Icons.house_rounded, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gh['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                gh['device_code'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGreenhouse = value;
                  });
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Mostrando datos de: $selectedGreenhouse',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildDummyGrid(),
      ],
    );
  }

  // ---- Grid de dummy data ----
  Widget _buildDummyGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildCard('Riego', 'Próximo en: 2 días', const Color(0xFFBBDEFB), Icons.water_drop),
        _buildCard('Clima', 'Calidad ambiental:\nAceptable', const Color(0xFFFFF59D), Icons.wb_sunny_outlined),
        _buildCard('Alertas', '3 alarmas activas', const Color(0xFFFFCC80), Icons.warning_amber_outlined),
        _buildCard('Salud', 'Excelente', const Color(0xFFC8E6C9), Icons.health_and_safety_outlined),
      ],
    );
  }

  // ---- Bottom Navigation Bar ----
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

  // ---- Tarjeta reutilizable ----
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
