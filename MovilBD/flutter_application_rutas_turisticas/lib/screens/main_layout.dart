import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/home.dart';
import 'package:flutter_application_rutas_turisticas/screens/mapa.dart';
import 'package:flutter_application_rutas_turisticas/screens/rutas.dart';
import 'package:flutter_application_rutas_turisticas/screens/favoritos.dart';
import 'package:flutter_application_rutas_turisticas/screens/perfil.dart';
import 'package:flutter_application_rutas_turisticas/screens/feed_screen.dart'; // Nuevo Feed
import 'package:flutter_application_rutas_turisticas/screens/create_post.dart'; // Nuevo Post

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Índice de la pestaña seleccionada
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    const FeedScreen(), // 0. Inicio (Reels)
    const Mapa(),       // 1. Mapa (Antes Explorar)
    const SizedBox(),   // 2. Publicar (Placeholder)
    const Rutas(),      // 3. Rutas
    const Perfil(),     // 4. Perfil
  ];

  // Función que se llama cuando se toca un ícono de la barra
  void _onItemTapped(int index) {
    if (index == 2) {
      // Si toca el botón central (+), abrimos la pantalla de crear post modalmente
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePostScreen()),
      ).then((_) {
        // Al regresar, tal vez refrescar feed?
      });
      return; 
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el color púrpura de tu app
    final Color activeColor = Theme.of(context).primaryColor; 
    
    // Check keyboard for visibility (optional polish)

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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40, color: Colors.purple),
            activeIcon: Icon(Icons.add_circle, size: 40, color: Colors.purple),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_outlined),
            activeIcon: Icon(Icons.directions_bus),
            label: 'Rutas',
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

