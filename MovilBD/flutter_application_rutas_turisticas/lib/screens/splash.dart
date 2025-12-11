import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatetoHome();
  }

  // Tiempo de espera antes de navegar a la pantalla de Login
  _navigatetoHome() async {
    await Future.delayed(
      const Duration(milliseconds: 5000),
      () {},
    ); // Puedes ajustar este tiempo

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color logoTextColor = Color(0xFFFDD835);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset('assets/Fondo_Splash.png', fit: BoxFit.cover),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Logo.png', height: 120, width: 120),
                const SizedBox(height: 15),
                const Text(
                  "RT Mobile",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color:
                        logoTextColor, // Usamos el color definido para el logo
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
