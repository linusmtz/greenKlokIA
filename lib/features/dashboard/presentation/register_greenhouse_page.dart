import 'package:flutter/material.dart';
import 'package:green_klok_ia/services/greenhouse_service.dart';

class RegisterGreenhousePage extends StatefulWidget {
  const RegisterGreenhousePage({super.key});

  @override
  State<RegisterGreenhousePage> createState() => _RegisterGreenhousePageState();
}

class _RegisterGreenhousePageState extends State<RegisterGreenhousePage> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _service = GreenhouseService();

  bool _loading = false;

  Future<void> _register() async {
    final code = _codeCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    if (code.isEmpty || name.isEmpty) {
      _showSnack('⚠️ Ingresa el código y nombre del invernadero', Colors.orange);
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await _service.registerGreenhouse(
        activationCode: code,
        greenhouseName: name,
      );

      if (result['ok']) {
        _showSnack('✅ ${result['message']}', Colors.green);
        Navigator.pop(context, true); // regresa al dashboard
      } else {
        _showSnack('⚠️ ${result['message']}', Colors.red);
      }
    } catch (e) {
      _showSnack('❌ Error de conexión: $e', Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Invernadero'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el código que viene en la caja del invernadero 🌱',
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _codeCtrl,
              decoration: InputDecoration(
                labelText: 'Código de activación',
                prefixIcon: const Icon(Icons.qr_code_2, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre del invernadero',
                prefixIcon: const Icon(Icons.eco, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _register,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  _loading ? 'Registrando...' : 'Registrar invernadero',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
