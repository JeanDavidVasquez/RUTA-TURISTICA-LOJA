import 'package:flutter/material.dart';
import '../models/publicacion.dart';
import '../services/api_service.dart';
import 'details_places.dart';
import 'home.dart';
import 'post_detail.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rutas Turísticas Loja',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: "Explorar"),
            Tab(text: "Vivencias"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Home(),          // Pestaña 1: Explorar Lugares
          _VivenciasTab(), // Pestaña 2: Feed de Publicaciones
        ],
      ),
    );
  }
}

class _VivenciasTab extends StatefulWidget {
  const _VivenciasTab();

  @override
  State<_VivenciasTab> createState() => _VivenciasTabState();
}

class _VivenciasTabState extends State<_VivenciasTab> {
  final ApiService _apiService = ApiService();
  late Future<List<Publicacion>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _refreshFeed();
  }

  void _refreshFeed() {
    setState(() {
      _feedFuture = _apiService.fetchPublicaciones(); // Fetch global feed
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Publicacion>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text("No hay publicaciones aún. ¡Sé el primero!"));
        }

        final posts = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            _refreshFeed();
          },
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(posts[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Publicacion post) {
    // Logic: If user is owner, explicitly show "Propietario"
    // Also consider special types for coloring
    final bool isOwner = post.esPropietario;
    final bool isSpecial = post.tipo == 'PROMOCION' || post.tipo == 'EVENTO';
    
    final roleLabel = isOwner ? "Propietario" : "Turista";
    final roleColor = isOwner ? Colors.purple : Colors.blue;

    // Construct Image URL
    String? imageUrl = _apiService.getImageUrl(post.archivoMedia);

    return GestureDetector( 
      onTap: () {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
         ).then((_) => _refreshFeed()); // Refresh on return in case of deletion
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Usuario, Lugar y Rol
            ListTile(
              leading: CircleAvatar(
                backgroundImage: post.usuarioFoto != null
                    ? NetworkImage(post.usuarioFoto!)
                    : null,
                child: post.usuarioFoto == null
                    ? Text(post.usuarioUsername[0].toUpperCase())
                    : null,
              ),
              title: Row(
                children: [
                   Flexible(
                    child: Text(post.usuarioUsername,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: roleColor),
                    ),
                    child: Text(
                      roleLabel,
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: GestureDetector(
                onTap: () async {
                  try {
                    final lugar = await _apiService.getLugar(post.lugar);
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetalleLugarScreen(lugar: lugar)),
                      );
                    }
                  } catch (e) {
                    print("Error loading place: $e");
                  }
                },
                child: Text("📍 ${post.lugarNombre}",
                    style: const TextStyle(color: Colors.blue)),
              ),
              // We can add a specialized menu here if needed, but detail screen is better
            ),

             // Imagen
            if (imageUrl != null)
              Image.network(
                imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: Text("No se pudo cargar imagen"))),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                   return Container(
                    height: 300,
                    color: Colors.grey[100],
                    child: const Center(child: CircularProgressIndicator()),
                   );
                },
              ),

             // Descripcion
            if (post.descripcion != null && post.descripcion!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.all(12.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          text: post.usuarioUsername,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: " "),
                      TextSpan(text: post.descripcion),
                    ],
                  ),
                ),
              ),
              
            // Footer: Ver comentarios
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                "Ver los comentarios...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
