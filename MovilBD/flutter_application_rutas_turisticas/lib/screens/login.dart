// Asegúrate de importar font_awesome_flutter
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
// --- (NUEVO) Importamos la pantalla de Registro ---
import 'register.dart'; // Asegúrate que tu archivo se llame register.dart
import '../services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF8667F2);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login UI Clone',
      theme: ThemeData(
        primaryColor: primaryPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: primaryPurple, width: 2.0),
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    print("Login: Button pressed");
    setState(() {
      _isLoading = true;
    });

    try {
      print("Login: Calling API with ${_emailController.text}");
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );
      print("Login: API returned $response");

      if (response['status'] == 'success') {
        print("Login: Success, navigating to /main");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login exitoso!')),
          );
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        print("Login: Failed with message ${response['message']}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Error desconocido')),
          );
        }
      }
    } catch (e) {
      print("Login: Error caught $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      print("Login: Finally block");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color linkColor = Color(0xFF8667F2);
    const Color goldColor = Color(0xFFF3B63D);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 80),
              const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa tus credenciales',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: linkColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    );
                  },
                  child: const Text(
                    'Registrate',
                    style: TextStyle(
                      color: linkColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SocialButton(
                    color: goldColor,
                    icon: FontAwesomeIcons.google,
                    iconColor: Colors.black,
                  ),
                  SizedBox(width: 15),
                  SocialButton(
                    color: goldColor,
                    icon: FontAwesomeIcons.facebookF,
                    iconColor: Colors.black,
                  ),
                  SizedBox(width: 15),
                  SocialButton(
                    color: goldColor,
                    icon: FontAwesomeIcons.apple,
                    iconColor: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Image.asset(
                'assets/Logo.png',
                width: 100,
                height: 100,
                color: goldColor,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget de Botón Social (Duplicado aquí para que el archivo sea autónomo,
// pero idealmente iría en su propio archivo 'social_button.dart' e importado)
class SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      elevation: 1.0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          height: 50,
          child: Center(child: Icon(icon, color: iconColor, size: 22)),
        ),
      ),
    );
  }
}
