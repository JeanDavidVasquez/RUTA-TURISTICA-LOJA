import 'package:flutter/material.dart';
import 'register.dart';
import '../services/api_service.dart';

// Mantenemos el main y MyApp como estaban para que funcione el ejemplo
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        primaryColor: const Color(0xFF8667F2),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white, // Aunque ya no se verá mucho
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
  // --- LÓGICA INTACTA ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.login(_emailController.text, _passwordController.text);
      if (response['status'] == 'success') {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? 'Error'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // ----------------------

  @override
  Widget build(BuildContext context) {
    const Color brandPurple = Color(0xFF8667F2);
    // Usamos la altura total de la pantalla
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Usamos resizeToAvoidBottomInset false para manejar el teclado nosotros si es necesario,
      // o true si queremos que suba todo. Probemos true primero.
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. IMAGEN DE FONDO INMERSIVA
          Positioned.fill(
            child: Image.asset(
              'assets/Fondo_Splash.png', // Asegúrate que esta imagen exista
              fit: BoxFit.cover,
            ),
          ),

          // 2. OVERLAY DEGRADADO (Para que se lea el texto blanco)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    brandPurple.withOpacity(0.4), // Morado transparente arriba
                    Colors.black.withOpacity(0.8), // Más oscuro abajo
                  ],
                ),
              ),
            ),
          ),

          // 3. CONTENIDO PRINCIPAL
          SingleChildScrollView(
            child: SizedBox(
              height: size.height, // Forzamos altura completa para distribuir
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Empuja todo hacia abajo
                children: [
                  // --- PARTE SUPERIOR (Logo y Bienvenida) ---
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'logo_auth',
                            child: Image.asset('assets/Logo.png', height: 100, color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Bienvenido",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Tu próxima aventura comienza aquí",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- TARJETA DEL FORMULARIO (Bottom Sheet style) ---
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Inputs modernos sin bordes duros
                        _buildModernInput(_emailController, "Correo electrónico", Icons.email_outlined),
                        const SizedBox(height: 20),
                        _buildModernInput(_passwordController, "Contraseña", Icons.lock_outline, isPassword: true),

                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.grey[600])),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // BOTÓN GRANDE Y LLAMATIVO
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: brandPurple.withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("INGRESAR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 30),
                        // FOOTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("¿No tienes cuenta? ", style: TextStyle(color: Colors.grey[600])),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Register())),
                              child: Text("Regístrate", style: TextStyle(color: brandPurple, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para los inputs "Soft UI"
  Widget _buildModernInput(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Fondo gris suave
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3436)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFF8667F2)), // Icono morado
          border: InputBorder.none, // Sin bordes
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}