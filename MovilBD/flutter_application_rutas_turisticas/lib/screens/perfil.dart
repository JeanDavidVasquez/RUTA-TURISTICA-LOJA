import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import '../models/lugar.dart'; // Import para Lugar
import 'editar_perfil.dart';
import 'favoritos.dart'; // Import Favorites
import '../models/publicacion.dart';
import 'post_detail.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final ApiService _apiService = ApiService();
  late Future<Usuario?> _futureUsuario;
  late Future<Map<String, dynamic>> _futureStats;
  
  // Lista de lugares administrados
  List<Lugar> _managedPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    int? userId = ApiService.currentUserId;
    if (userId != null) {
      _futureUsuario = _apiService.getUserProfile(userId);
      _futureStats = _apiService.getUserStats(userId);
      
      // Cargar lugares administrados
      try {
        final places = await _apiService.getManagedPlaces(userId);
        if (mounted) setState(() => _managedPlaces = places);
      } catch (e) {
        print("Error loading managed places: $e");
      }
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
                      const Text("Mi Perfil", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                      const Icon(Icons.settings_outlined, color: Colors.black87), // Simple icon
                    ],
                   ),
                   const SizedBox(height: 30),

                   // --- 2. USUARIO ---
                   Center(
                     child: Column(
                       children: [
                         // Avatar
                         CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF6C5CE7),
                            backgroundImage: usuario?.urlFotoPerfil != null
                                ? NetworkImage(usuario!.urlFotoPerfil!)
                                : null,
                            child: usuario?.urlFotoPerfil == null
                                ? Text(iniciales, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))
                                : null,
                          ),
                         const SizedBox(height: 16),
                         Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                         Text(email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                         const SizedBox(height: 10),
                         TextButton(
                           onPressed: () async {
                              if (usuario != null) {
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => EditarPerfilScreen(usuario: usuario)));
                                setState(() => _loadData());
                              }
                           },
                           child: const Text("Editar Perfil"),
                         )
                       ],
                     ),
                   ),

                   // --- 3. ESTADÍSTICAS ---
                   const SizedBox(height: 20),
                   FutureBuilder<Map<String, dynamic>>(
                      future: _futureStats,
                      builder: (context, statsSnapshot) {
                        final stats = statsSnapshot.data ?? {'favoritos': 0, 'visitados': 0, 'rutas': 0};
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildWhiteStatItem("Visitados", stats['visitados'].toString()),
                              _buildWhiteStatItem("Rutas", stats['rutas'].toString()),
                              _buildWhiteStatItem("Favoritos", stats['favoritos'].toString()),
                            ],
                          ),
                        );
                      }),
                   
                   // --- 4. GESTIÓN DE NEGOCIO (SI ES ADMIN) ---
                   if (_managedPlaces.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      const Align(alignment: Alignment.centerLeft, child: Text("Mi Negocio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 10),
                      
                      // Tarjeta de Admin
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.business_center, color: Colors.orange),
                          ),
                          title: Text("Administrar: ${_managedPlaces.first.nombre}"),
                          subtitle: const Text("Editar info, ver estadísticas"),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                             // Aquí iría al Dashboard del Negocio (Editar Info)
                             // Por ahora solo mostramos un SnackBar o Dialog
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Panel de Gestión: Próximamente")));
                          },
                        ),
                      ),
                   ],


                   // --- 5. MENU GRID ---
                   const SizedBox(height: 30),
                   const Align(alignment: Alignment.centerLeft, child: Text("General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
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
                        icon: Icons.star,
                        title: "Favoritos",
                        color: Colors.orange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Favoritos())),
                      ),
                      _buildGridButton(
                        icon: Icons.rate_review,
                        title: "Mis Reseñas",
                        color: Colors.pinkAccent,
                        onTap: () => Navigator.pushNamed(context, '/mis_resenas'),
                      ),
                      _buildGridButton(
                        icon: Icons.image,
                        title: "Mis Publicaciones",
                        color: Colors.purple,
                        onTap: () {
                          if (ApiService.currentUserId != null) {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => UserPostsScreen(userId: ApiService.currentUserId!))
                            );
                          }
                        },
                      ),
                      _buildGridButton(
                        icon: Icons.logout,
                        title: "Cerrar Sesión",
                        color: Colors.red,
                        onTap: () {
                          ApiService.currentUserId = null;
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                      ),
                    ],
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

  Widget _buildWhiteStatItem(String label, String count) {
    return Column(children: [Text(count, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))]);
  }

  Widget _buildGridButton({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class UserPostsScreen extends StatefulWidget {
  final int userId;
  const UserPostsScreen({super.key, required this.userId});

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  final ApiService _apiService = ApiService();
  List<Publicacion> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _apiService.fetchPublicaciones(usuarioId: widget.userId);
      if (mounted) setState(() { _posts = posts; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Publicaciones")),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _posts.isEmpty 
           ? const Center(child: Text("No has realizado publicaciones"))
           : ListView.builder(
               itemCount: _posts.length,
               itemBuilder: (context, index) {
                 final post = _posts[index];
                 return ListTile(
                   leading: post.archivoMedia != null 
                     ? Image.network(_apiService.getImageUrl(post.archivoMedia)!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c,e,s)=>const Icon(Icons.image)) 
                     : const Icon(Icons.article),
                   title: Text(post.descripcion ?? "Sin descripción", maxLines: 1, overflow: TextOverflow.ellipsis),
                   subtitle: Text("En: ${post.lugarNombre}"),
                   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                   onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)))
                       .then((_) => _loadPosts()); // Reload on return (in case of delete)
                   },
                 );
               },
             ),
    );
  }
}
