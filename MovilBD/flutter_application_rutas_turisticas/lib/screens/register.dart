import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // --- LÓGICA INTACTA ---
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.register(_usernameController.text, _emailController.text, _passwordController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cuenta creada!'), backgroundColor: Colors.green));
        Navigator.pop(context);
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Usamos resizeToAvoidBottomInset false para que el fondo no se deforme al abrir el teclado
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. IMAGEN DE FONDO
          Positioned.fill(
            child: Image.asset(
              'assets/Fondo_Splash.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. OVERLAY DEGRADADO
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    brandPurple.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. CONTENIDO PRINCIPAL
          SingleChildScrollView(
            child: SizedBox(
              height: size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // --- PARTE SUPERIOR (Botón atrás, Logo, Texto CENTRADOS) ---
                  Expanded(
                    child: SafeArea(
                      // Usamos Stack aquí para poder centrar el contenido independientemente del botón de atrás
                      child: Stack(
                        children: [
                          // Botón de Atrás (Esquina superior izquierda)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          // Contenido Centrado (Logo y Textos)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Para que se centre verticalmente
                                children: [
                                  Hero(
                                    tag: 'logo_auth',
                                    child: Image.asset('assets/Logo.png', height: 90, color: Colors.white),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    "Crear Cuenta",
                                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  // NUEVA FRASE AVENTURERA MÁS INSPIRADORA
                                  Text(
                                    "Despierta al explorador que llevas dentro y traza tu propia ruta.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17, // Un poco más grande
                                      color: Colors.white.withOpacity(0.95),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                      height: 1.3, // Mejor interlineado
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- TARJETA DEL FORMULARIO ---
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
                        _buildModernInput(_usernameController, "Nombre de usuario", Icons.person_outline_rounded),
                        const SizedBox(height: 20),
                        _buildModernInput(_emailController, "Correo electrónico", Icons.email_outlined),
                        const SizedBox(height: 20),
                        _buildModernInput(_passwordController, "Contraseña", Icons.lock_outline, isPassword: true),

                        const SizedBox(height: 30),

                        // BOTÓN DE REGISTRO
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: brandPurple.withOpacity(0.5),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("REGISTRARSE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("¿Ya tienes cuenta? ", style: TextStyle(color: Colors.grey[600])),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text("Inicia sesión", style: TextStyle(color: brandPurple, fontWeight: FontWeight.bold)),
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

  // Widget auxiliar de input (Igual que en Login)
  Widget _buildModernInput(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3436)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: const Color(0xFF8667F2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}