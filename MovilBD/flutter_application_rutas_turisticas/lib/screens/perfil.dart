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
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // --- 1. CABECERA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Perfil",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Modo oscuro próximamente"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.nightlight_round, size: 28),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 20),

              // --- 2. TARJETA DE PERFIL ---
              FutureBuilder<Usuario?>(
                future: _futureUsuario,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  final usuario = snapshot.data;
                  final nombre = usuario?.nombreDisplay ?? "Invitado";
                  final email = usuario?.email ?? "Inicia sesión para ver tus datos";
                  final iniciales = nombre.isNotEmpty ? nombre.substring(0, 2).toUpperCase() : "IN";

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: primaryColor,
                              backgroundImage: usuario?.urlFotoPerfil != null
                                  ? NetworkImage(usuario!.urlFotoPerfil!)
                                  : null,
                              child: usuario?.urlFotoPerfil == null
                                  ? Text(
                                      iniciales,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // --- ESTADÍSTICAS ---
                        FutureBuilder<Map<String, dynamic>>(
                          future: _futureStats,
                          builder: (context, statsSnapshot) {
                            if (!statsSnapshot.hasData) {
                              return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
                            }
                            final stats = statsSnapshot.data!;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  context,
                                  icon: Icons.location_on_outlined,
                                  count: stats['visitados'].toString(),
                                  label: "Visitados",
                                ),
                                _buildStatItem(
                                  context,
                                  icon: Icons.map_outlined,
                                  count: stats['rutas'].toString(),
                                  label: "Rutas",
                                ),
                                _buildStatItem(
                                  context,
                                  icon: Icons.favorite_border,
                                  count: stats['favoritos'].toString(),
                                  label: "Favoritos",
                                ),
                              ],
                            );
                          }
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // --- 3. BOTONES DE MENÚ ---
              _buildMenuButton(
                icon: Icons.edit_outlined,
                text: "Editar Perfil",
                onTap: () async {
                  final usuario = await _futureUsuario;
                  if (usuario != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditarPerfilScreen(usuario: usuario)),
                    );
                    if (result == true) {
                      setState(() {
                        _loadData(); // Recargar datos si hubo cambios
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                icon: Icons.notifications_none,
                text: "Notificaciones",
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                icon: Icons.logout,
                text: "Cerrar sesión",
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  ApiService.currentUserId = null; // Clear session
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String count,
    required String label,
  }) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color textColor = Colors.black,
    Color iconColor = Colors.black87,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
