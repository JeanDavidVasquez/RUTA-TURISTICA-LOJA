import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import 'editar_perfil.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final ApiService _apiService = ApiService();
  late Future<Usuario?> _futureUsuario;
  late Future<Map<String, dynamic>> _futureStats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    int? userId = ApiService.currentUserId;
    if (userId != null) {
      _futureUsuario = _apiService.getUserProfile(userId);
      _futureStats = _apiService.getUserStats(userId);
    } else {
      _futureUsuario = Future.value(null);
      _futureStats = Future.value({'favoritos': 0, 'visitados': 0, 'rutas': 0});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: FutureBuilder<Usuario?>(
        future: _futureUsuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final usuario = snapshot.data;
          final nombre = usuario?.nombreDisplay ?? "Invitado";
          final email = usuario?.email ?? "Inicia sesión";
          final iniciales = nombre.isNotEmpty ? nombre.substring(0, 2).toUpperCase() : "IN";

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // --- 1. HEADER ---
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Mi Perfil",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- 2. SECCIÓN DE USUARIO (CENTRADO) ---
                  Center(
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF6C5CE7),
                            backgroundImage: usuario?.urlFotoPerfil != null
                                ? NetworkImage(usuario!.urlFotoPerfil!)
                                : null,
                            child: usuario?.urlFotoPerfil == null
                                ? Text(
                              iniciales,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- CAMBIO: NOMBRE Y CORREO PARALELOS Y CENTRADOS ---
                        // Usamos MainAxisSize.min para que la fila abrace el contenido
                        // y quede perfectamente centrada en la pantalla.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                            ),

                            // Separador Vertical (Línea)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              height: 16,
                              width: 1.5,
                              color: Colors.grey[300],
                            ),

                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // -------------------------------------------

                        const SizedBox(height: 20),

                        // Botón Editar Pequeño
                        InkWell(
                          onTap: () async {
                            if (usuario != null) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditarPerfilScreen(usuario: usuario)),
                              );
                              setState(() {
                                _loadData();
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C5CE7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Editar Perfil",
                              style: TextStyle(
                                color: Color(0xFF6C5CE7),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 3. TARJETA DE ESTADÍSTICAS ---
                  FutureBuilder<Map<String, dynamic>>(
                      future: _futureStats,
                      builder: (context, statsSnapshot) {
                        final stats = statsSnapshot.data ??
                            {'favoritos': 0, 'visitados': 0, 'rutas': 0};

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildWhiteStatItem("Visitados", stats['visitados'].toString()),
                              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                              _buildWhiteStatItem("Rutas", stats['rutas'].toString()),
                              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                              _buildWhiteStatItem("Favoritos", stats['favoritos'].toString()),
                            ],
                          ),
                        );
                      }),

                  const SizedBox(height: 30),

                  // --- 4. MENÚ EN PARALELO (GRID) ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "General",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildGridButton(
                        icon: Icons.notifications_none_rounded,
                        title: "Notificaciones",
                        color: Colors.orange,
                        onTap: () {},
                      ),
                      _buildGridButton(
                        icon: Icons.rate_review_outlined,
                        title: "Mis Reseñas",
                        color: Colors.pinkAccent,
                        onTap: () => Navigator.pushNamed(context, '/mis_resenas'),
                      ),
                      _buildGridButton(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacidad",
                        color: Colors.teal,
                        onTap: () {},
                      ),
                      _buildGridButton(
                        icon: Icons.help_outline_rounded,
                        title: "Ayuda",
                        color: Colors.blueAccent,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: TextButton(
                      onPressed: () {
                        ApiService.currentUserId = null;
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF5F5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text(
                            "Cerrar Sesión",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhiteStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGridButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}