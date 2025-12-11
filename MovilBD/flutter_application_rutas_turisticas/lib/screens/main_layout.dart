import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/home.dart';
import 'package:flutter_application_rutas_turisticas/screens/mapa.dart';
import 'package:flutter_application_rutas_turisticas/screens/rutas.dart';
import 'package:flutter_application_rutas_turisticas/screens/favoritos.dart';
import 'package:flutter_application_rutas_turisticas/screens/perfil.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Índice de la pestaña seleccionada
  int _selectedIndex = 0;

  // --- CORRECCIÓN AQUÍ ---
  // Cambiamos 'static const' por 'final List<Widget>'.
  // Esto permite que las pantallas cambien o reciban argumentos sin dar error.
  final List<Widget> _widgetOptions = [
    const Home(), // Índice 0
    const Rutas(), // Índice 1
    const Mapa(), // Índice 2
    const Favoritos(), // Índice 3
    const Perfil(), // Índice 4
  ];

  // Función que se llama cuando se toca un ícono de la barra
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el color púrpura de tu app
    final Color activeColor = Theme.of(
      context,
    ).primaryColor; // Mejor usar el del tema

    return Scaffold(
      // El body es la página seleccionada actualmente
      body: Center(
        // Usamos elementAt para obtener el widget de la lista
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      // Esta es la barra de navegación inferior
      bottomNavigationBar: BottomNavigationBar(
        // Los items (íconos y etiquetas) de la barra
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.public_outlined),
            activeIcon: Icon(Icons.public),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Rutas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            activeIcon: Icon(Icons.star),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],

        // --- Configuración de Estilos ---
        currentIndex: _selectedIndex,
        selectedItemColor: activeColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
