import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Asegúrate de que login.dart esté en la misma carpeta o ajusta la ruta
// (Aunque solo usamos Navigator.pop() para regresar, es bueno ser consistente)

import '../services/api_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Usamos el nombre como username por simplicidad
      await _apiService.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso! Por favor inicia sesión.')),
        );
        Navigator.pop(context); // Regresar al Login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Reutilizamos el mismo método constructor de botones sociales
  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      elevation: 1.0, // Sombra sutil
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 50, // Más cuadrado
          height: 50,
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 22, // Tamaño de icono
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores definidos en la pantalla de Login, los reutilizamos
    const Color linkColor = Color(0xFF8667F2);
    const Color goldColor = Color(0xFFF3B63D);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 60,
              ), // Menos espacio superior para más campos
              const Text(
                'REGISTER', // Título cambiado
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea tu cuenta',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // --- Nuevos Campos de Registro ---
              // Fila para Nombre y Apellido
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(hintText: 'Username'),
              ),
              const SizedBox(height: 16),
              // Campo de Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Campo de Contraseña
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
                obscureText: true,
              ),
              // --- Fin de Nuevos Campos ---

              // Eliminamos el 'Olvidaste tu contraseña?'
              const SizedBox(height: 30),
              // Botón de Submit (usa el tema global)
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit'),
              ),
              const SizedBox(height: 30),
              const Text(
                'Or continue with',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Botones sociales (idénticos a Login)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildSocialButton(
                    color: goldColor,
                    icon: FontAwesomeIcons.google,
                    iconColor: Colors.black,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 15),
                  _buildSocialButton(
                    color: goldColor,
                    icon: FontAwesomeIcons.facebookF,
                    iconColor: Colors.black,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 15),
                  _buildSocialButton(
                    color: goldColor,
                    icon: FontAwesomeIcons.apple,
                    iconColor: Colors.black,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- Enlace para regresar a Login ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: () {
                      // Simplemente regresa a la pantalla anterior (Login)
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: linkColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Logo (idéntico a Login)
              Image.asset(
                'assets/Logo.png',
                width: 80, // Un poco más pequeño para que quepa todo
                height: 80,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
