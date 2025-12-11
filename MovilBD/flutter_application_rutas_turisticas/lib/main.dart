import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/login.dart';
import 'package:flutter_application_rutas_turisticas/screens/main_layout.dart';
import 'package:flutter_application_rutas_turisticas/screens/register.dart';
import 'package:flutter_application_rutas_turisticas/screens/splash.dart';
import 'package:flutter_application_rutas_turisticas/screens/test_connection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color targetPurple = Color(0xFF8667F2);

    return MaterialApp(
      title: 'Rutas Turísticas',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: targetPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: targetPurple,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
            borderSide: const BorderSide(color: targetPurple, width: 2.0),
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: const Splash(),
      // home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const Register(),
        '/main': (context) => const MainLayout(),
        //'/test_connection': (context) => const TestConnectionScreen(),
      },
    );
  }
}
