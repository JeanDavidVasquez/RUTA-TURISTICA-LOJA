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
    // Definimos el color morado de la marca
    const Color brandPurple = Color(0xFF8667F2);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 1. LA FOTO DE FONDO (Se mantiene)
          Image.asset(
            'assets/Fondo_Splash.png',
            fit: BoxFit.cover,
          ),

          // 2. CAPA DE OSCURECIMIENTO (Se mantiene para contraste)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // 3. CONTENIDO CENTRADO EN MORADO
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO (Ahora en morado)
                  Hero(
                    tag: 'logo_splash',
                    child: Image.asset(
                      'assets/Logo.png',
                      height: 140,
                      width: 140,
                      color: brandPurple, // <-- CAMBIO AQUÍ
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TÍTULO DE LA APP (Ahora en morado)
                  const Text(
                    "RT Mobile",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: brandPurple, // <-- CAMBIO AQUÍ
                      letterSpacing: 1.0,
                      shadows: [
                        // Sombra negra suave para que el morado se lea bien sobre el fondo oscuro
                        Shadow(offset: Offset(0, 2), blurRadius: 5, color: Colors.black)
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FRASE DE BIENVENIDA (Ahora en morado)
                  Text(
                    "Hola de nuevo,\nbienvenido a la aventura.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: brandPurple.withOpacity(0.9), // <-- CAMBIO AQUÍ (un poco más suave)
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. LOADER (También en morado)
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: brandPurple, // <-- CAMBIO AQUÍ
                strokeWidth: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}