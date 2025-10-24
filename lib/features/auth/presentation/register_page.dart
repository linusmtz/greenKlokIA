import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:green_klok_ia/routes/app_routes.dart';
import 'package:green_klok_ia/services/auth_service.dart';

/// Pantalla de registro de usuario.
///
/// Contiene un formulario con validaciones para nombre, correo,
/// teléfono, contraseña y fecha de nacimiento. Al enviar, hace una
/// llamada a `AuthService.register` y muestra feedback con `SnackBar`.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Key para el formulario que permite validar todos los campos
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controladores para los campos del formulario
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();

  // Estado local para mostrar/ocultar la contraseña y para mostrar
  // un indicador de carga mientras se registra.
  bool _obscurePass = true;
  bool _loading = false;

  // Colores reutilizables para mantener la coherencia visual
  final green = const Color(0xFF2E7D32);
  final lightGreen = const Color(0xFFDFFFD8);

  /// Abre un selector de fecha para elegir la fecha de nacimiento.
  ///
  /// Si el usuario selecciona una fecha, la formatea como `dd/MM/yyyy`
  /// y la coloca en `_birthController`.
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  /// Valida el formulario y envía los datos al servicio de autenticación.
  ///
  /// Muestra un `CircularProgressIndicator` mientras espera la respuesta
  /// y usa `SnackBar` para mostrar mensajes de éxito o error.
  Future<void> _validateAndSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      final res = await _authService.register(name, email, phone, password);

      setState(() => _loading = false);

      if (res['ok']) {
        // Mostrar mensaje devuelto por el servidor y volver al login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${res['message']}')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        // Mostrar error devuelto por la API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${res['msg']}')),
        );
      }
    } catch (e) {
      // En caso de excepción, ocultar el loader y mostrar el error
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón para volver a la pantalla anterior
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Nueva Cuenta',
                    style: TextStyle(
                      color: green,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Campos del formulario: nombre, contraseña, correo, teléfono y fecha
                _buildField(
                  'Nombre completo',
                  _nameController,
                  hint: 'Memo Capibara',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildField(
                  'Correo electrónico',
                  _emailController,
                  hint: 'example@example.com',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'El correo es obligatorio';
                    final emailRegExp = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegExp.hasMatch(v.trim())) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  'Número de teléfono móvil',
                  _phoneController,
                  hint: '8712312134',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'El número es obligatorio';
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(v.trim())) {
                      return 'Número no válido (10 dígitos)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Al continuar, aceptas los Términos de uso y la Política de privacidad.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Inscribirse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        text: '¿Ya tienes cuenta? ',
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(
                              color: green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye un campo de texto con etiqueta y validación opcional.
  Widget _buildField(String label, TextEditingController controller,
      {String? hint,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }

  /// Construye el campo de contraseña con botón para mostrar/ocultar.
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePass,
          validator: (v) =>
              v == null || v.isEmpty ? 'La contraseña es obligatoria' : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: lightGreen,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: green,
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
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
      ],
    );
  }

  /// Campo para seleccionar la fecha de nacimiento (readOnly, abre picker).
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha de nacimiento',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _birthController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            hintText: 'DD / MM / YYYY',
            filled: true,
            fillColor: lightGreen,
            suffixIcon: Icon(Icons.calendar_today, color: green),
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
      ],
    );
  }
}
