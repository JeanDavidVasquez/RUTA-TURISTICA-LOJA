import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/details_places.dart'; 
import 'package:flutter_application_rutas_turisticas/screens/detalle_ruta.dart';
import '../services/api_service.dart';
import '../models/lugar.dart';
import '../models/ruta.dart';
import '../models/categoria.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ApiService _apiService = ApiService();

  // Data Sources
  List<Lugar> _allLugares = [];
  List<Lugar> _filteredLugares = [];
  List<Ruta> _allRutas = [];
  List<Ruta> _filteredRutas = [];

  // State
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedCategory = "Todos";
  final TextEditingController _searchController = TextEditingController();

  // Categories
  List<Categoria> _categories = [];

  // --- Estado para manejar los favoritos visualmente ---
  final Set<int> _favoritosIds = {}; 

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  // --- Función para dar Like y llamar a la API ---
  Future<void> _toggleFavorite(int lugarId) async {
    bool isLiked = _favoritosIds.contains(lugarId);
    bool newStatus = !isLiked;

    // 1. Actualización Optimista (Visual inmediata)
    setState(() {
      if (isLiked) {
        _favoritosIds.remove(lugarId); // Quitar like
      } else {
        _favoritosIds.add(lugarId); // Dar like
      }
    });

    try {
      // 2. LLAMADA A LA BASE DE DATOS
      await _apiService.toggleFavorito(lugarId, 'FAV', newStatus);
      print("Like guardado en servidor para ID: $lugarId, Estado: $newStatus");
    } catch (e) {
      // 3. Revertir si falla el servidor
      setState(() {
        if (!newStatus) { 
           _favoritosIds.add(lugarId);
        } else { 
           _favoritosIds.remove(lugarId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  // --- CORRECCIÓN AQUÍ: Cargamos también los favoritos al iniciar ---
  Future<void> _fetchData() async {
    try {
      // 1. Carga paralela de datos básicos
      final result = await Future.wait([
        _apiService.fetchLugares(),
        _apiService.fetchRutas(),
        _apiService.fetchCategorias(),
      ]);

      final lugares = result[0] as List<Lugar>;
      final rutas = result[1] as List<Ruta>;
      final allCategorias = result[2] as List<Categoria>;

      // 2. IMPORTANTE: Recuperar los favoritos guardados en la BD
      // Esto evita que se borren los corazones al recargar o cambiar de pestaña
      final favoritosGuardados = await _apiService.fetchUserFavoritos('FAV');
      final Set<int> idsFavoritosRecuperados = favoritosGuardados.map((l) => l.id).toSet();

      // 3. Filtrar categorías
      final Set<int> usedCategoryIds = {};
      for (var lugar in lugares) {
        for (var cat in lugar.categorias) {
          usedCategoryIds.add(cat.id);
        }
      }
      for (var ruta in rutas) {
        for (var cat in ruta.categorias) {
          usedCategoryIds.add(cat.id);
        }
      }

      final usedCategories = allCategorias
          .where((cat) => usedCategoryIds.contains(cat.id))
          .toList();

      if (mounted) {
        setState(() {
          _allLugares = lugares;
          _allRutas = rutas;
          _categories = usedCategories;
          _filteredLugares = lugares;
          _filteredRutas = rutas;
          
          // Asignamos los favoritos que vinieron de la base de datos
          _favoritosIds.addAll(idsFavoritosRecuperados);
          
          _isLoading = false;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print("Error en fetchData: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchQuery.toLowerCase();

    // Filter Places
    _filteredLugares = _allLugares.where((lugar) {
      final matchesSearch = lugar.nombre.toLowerCase().contains(query) ||
          (lugar.direccionCompleta?.toLowerCase().contains(query) ?? false);

      final matchesCategory = _selectedCategory == "Todos" ||
          lugar.categorias.any((cat) => cat.nombre == _selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();

    // Filter Routes
    _filteredRutas = _allRutas.where((ruta) {
      final matchesSearch = ruta.nombre.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == "Todos" ||
          ruta.categorias.any((cat) => cat.nombre == _selectedCategory);

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = const Color(0xFFF7F7F7); 

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(primaryColor),
                  ),
                  SliverToBoxAdapter(
                    child: _buildCategories(primaryColor),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  if (_filteredRutas.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildSectionTitle("Rutas Populares", () {}),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 160,
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredRutas.length,
                          itemBuilder: (context, index) {
                            return _buildRouteCard(_filteredRutas[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                  if (_filteredLugares.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          "Explora Loja",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                    ),
                  if (_filteredLugares.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildTemuStyleCard(_filteredLugares[index]);
                          },
                          childCount: _filteredLugares.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeader(Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
              const SizedBox(width: 4),
              const Text(
                "Loja, Ecuador",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: Colors.grey[100],
                radius: 18,
                child: const Icon(Icons.notifications_outlined, color: Colors.black87, size: 20),
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar lugares, rutas...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(Color primaryColor) {
    return Container(
      color: Colors.white,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          String name = index == 0 ? "Todos" : _categories[index - 1].nombre;
          bool isSelected = _selectedCategory == name;

          return GestureDetector(
            onTap: () => _onCategorySelected(name),
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border(bottom: BorderSide(color: primaryColor, width: 2)))
                  : null,
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? primaryColor : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onTap,
            child: Text("Ver todo", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(Ruta ruta) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleRutaScreen(ruta: ruta))),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.network(
                ruta.urlImagenPortada ?? "",
                width: 100,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c,e,s) => Container(width: 100, color: Colors.grey[300], child: const Icon(Icons.map)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(ruta.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text("${ruta.distanciaEstimadaKm} km", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TARJETA ESTILO TEMU ---
  Widget _buildTemuStyleCard(Lugar lugar) {
    bool isLiked = _favoritosIds.contains(lugar.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: InkWell(
        // Navegamos al detalle y esperamos si cambió el estado
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalleLugarScreen(
                lugar: lugar,
                initialFavState: isLiked, // Pasamos el estado actual
              ),
            ),
          );

          // Si vuelve con un dato, actualizamos localmente
          if (result != null && result is bool) {
            setState(() {
              if (result) {
                _favoritosIds.add(lugar.id);
              } else {
                _favoritosIds.remove(lugar.id);
              }
            });
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        lugar.urlImagenPrincipal ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                         // Llama a la API y cambia estado visual
                        _toggleFavorite(lugar.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 18, 
                          color: isLiked ? Colors.redAccent : Colors.black, 
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lugar.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      const Text("4.8", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text("• ${lugar.provincia ?? 'Loja'}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
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
}