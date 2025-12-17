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

  _navigatetoHome() async {
    await Future.delayed(const Duration(milliseconds: 4000), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tu color morado de marca
    const Color brandPurple = Color(0xFF8667F2);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 1. FOTO DE FONDO (Se mantiene)
          Image.asset(
            'assets/Fondo_Splash.png',
            fit: BoxFit.cover,
          ),

          // 2. CAPA BLANCA TRANSLÚCIDA (Overlay)
          // Esto es necesario para que las letras MORADAS se lean sobre la foto
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92), // Ajusta opacidad si quieres ver más foto
            ),
          ),

          // 3. CONTENIDO CENTRADO Y MORADO
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO (Color Morado)
                  Hero(
                    tag: 'logo_splash',
                    child: Image.asset(
                      'assets/Logo.png',
                      height: 140,
                      width: 140,
                      color: brandPurple, // EL LOGO AHORA ES MORADO
                    ),
                  ),

                  const SizedBox(height: 25),

                  // TÍTULO (Color Morado)
                  const Text(
                    "RT Mobile",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: brandPurple, // TEXTO MORADO
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FRASE DE BIENVENIDA (Color Morado Oscuro)
                  Text(
                    "Hola de nuevo,\nbienvenido a la aventura.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: brandPurple.withOpacity(0.8), // Un tono un poco más suave
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. LOADER (Morado)
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: brandPurple,
                strokeWidth: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}