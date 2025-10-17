import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  final green = const Color(0xFF2E7D32);
  final lightGreen = const Color(0xFFDFFFD8);

  void _submit() {
    final p1 = _pass1.text.trim();
    final p2 = _pass2.text.trim();

    if (p1.isEmpty || p2.isEmpty) {
      _toast('Completa ambos campos');
      return;
    }
    if (p1.length < 8) {
      _toast('La contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (p1 != p2) {
      _toast('Las contraseñas no coinciden');
      return;
    }

    _toast('Contraseña actualizada ✅');
    Navigator.pop(context);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Establecer Contraseña',
                  style: TextStyle(
                    color: green,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ingresa tu nueva contraseña y confírmala para continuar.',
                style: TextStyle(color: Colors.grey[700], fontSize: 13.5),
              ),
              const SizedBox(height: 24),

              // Contraseña
              const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _pass1,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: lightGreen,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: green,
                    ),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
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

              const SizedBox(height: 20),

              // Confirmar contraseña
              const Text('Confirmar Contraseña', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _pass2,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: lightGreen,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: green,
                    ),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
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

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Crear Nueva Contraseña',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
