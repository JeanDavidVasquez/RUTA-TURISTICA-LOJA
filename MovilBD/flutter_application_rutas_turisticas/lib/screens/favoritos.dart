import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/details_places.dart';
import '../services/api_service.dart';
import '../models/lugar.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({super.key});

  @override
  State<Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mis Listas",
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Favoritos"),
            Tab(text: "Por Visitar"),
            Tab(text: "Visitados"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('FAV'),
          _buildList('PEND'),
          _buildList('VISIT'),
        ],
      ),
    );
  }

  Widget _buildList(String tipo) {
    return FutureBuilder<List<Lugar>>(
      future: _apiService.fetchUserFavoritos(tipo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(tipo);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildPlaceCard(snapshot.data![index], tipo);
          },
        );
      },
    );
  }

  Widget _buildPlaceCard(Lugar lugar, String tipo) {
    final primaryColor = Theme.of(context).primaryColor;
    IconData actionIcon;
    Color iconColor;

    if (tipo == 'FAV') {
      actionIcon = Icons.favorite;
      iconColor = Colors.red;
    } else if (tipo == 'PEND') {
      actionIcon = Icons.watch_later;
      iconColor = Colors.blue;
    } else {
      actionIcon = Icons.check_circle;
      iconColor = Colors.green;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetalleLugarScreen(lugar: lugar)),
        ).then((_) {
          // Recargar la lista al volver por si cambió el estado
          setState(() {});
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      lugar.urlImagenPrincipal ?? "https://via.placeholder.com/400x300",
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Icon(Icons.image,
                          size: 50, color: Colors.grey[400]),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Icon(actionIcon, size: 20, color: iconColor),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lugar.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lugar.direccionCompleta ?? "Sin dirección",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String tipo) {
    String text = "";
    IconData icon = Icons.help_outline;

    if (tipo == 'FAV') {
      text = "No tienes favoritos aún.";
      icon = Icons.favorite_border;
    } else if (tipo == 'PEND') {
      text = "Tu lista de pendientes está vacía.";
      icon = Icons.watch_later_outlined;
    } else {
      text = "Aún no has visitado lugares.";
      icon = Icons.beenhere_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}
