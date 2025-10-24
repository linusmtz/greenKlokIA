import 'package:flutter/material.dart';
import 'package:green_klok_ia/routes/app_routes.dart';

/// Página para iniciar el proceso de recuperación de contraseña.
///
/// Permite al usuario introducir su correo electrónico registrado. Al
/// enviar, se valida el formato básico del correo y se muestra un
/// `SnackBar` con el resultado. En la implementación real deberías llamar
/// a tu API para generar y enviar el enlace de recuperación.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Controlador para el campo de email
  final _emailController = TextEditingController();

  // Colores reutilizables para mantener consistencia visual
  final green = const Color(0xFF2E7D32);
  final lightGreen = const Color(0xFFDFFFD8);

  /// Maneja el envío del formulario.
  ///
  /// Realiza una validación mínima (no vacío y contiene '@'). Si falla,
  /// muestra un `SnackBar` con un mensaje de error. Si pasa, muestra un
  /// mensaje de éxito y navega a la pantalla de restablecimiento.
  ///
  /// NOTA: aquí debes reemplazar la lógica de ejemplo por la llamada a tu
  /// backend que envíe el correo con el enlace de recuperación.
  void _submit() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un correo válido')),
      );
      return;
    }

    // Muestra feedback al usuario. En producción podrías mostrar un
    // indicador de carga mientras esperas la respuesta del servidor.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se ha enviado un enlace de recuperación')),
    );

    // Navegación de ejemplo: reemplaza la ruta según tu flujo.
    // `pushReplacementNamed` evita que el usuario regrese a esta pantalla
    // con el botón atrás.
    Navigator.pushReplacementNamed(context, AppRoutes.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding alrededor del contenido para que no quede pegado a los
          // bordes en pantallas pequeñas.
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botón para volver a la pantalla anterior
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              const SizedBox(height: 10),

              // Título centrado
              Center(
                child: Text(
                  'Recuperar Contraseña',
                  style: TextStyle(
                    color: green,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Descripción con instrucciones para el usuario
              Text(
                'Ingresa tu correo electrónico registrado y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Etiqueta del campo de correo
              const Text(
                'Correo electrónico',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // Campo de texto para introducir el correo
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
              const SizedBox(height: 32),

              // Botón para enviar la solicitud de recuperación
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
                    'Enviar enlace de recuperación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
