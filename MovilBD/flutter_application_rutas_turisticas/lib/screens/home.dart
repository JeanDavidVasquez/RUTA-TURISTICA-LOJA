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

  Future<void> _fetchData() async {
    try {
      final lugares = await _apiService.fetchLugares();
      final rutas = await _apiService.fetchRutas();
      final allCategorias = await _apiService.fetchCategorias();

      // Filter categories to only show those that have at least one place or route
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
          _isLoading = false;
          _applyFilters(); // Apply filters initially
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(primaryColor),
            _buildCategories(primaryColor),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_filteredLugares.isEmpty && _filteredRutas.isEmpty)
                              _buildEmptyState(),
                            
                            if (_filteredLugares.isNotEmpty) ...[
                              _buildSectionTitle("Lugares Destacados", () {}),
                              const SizedBox(height: 16),
                              _buildHorizontalList(
                                data: _filteredLugares,
                                isRoute: false,
                              ),
                              const SizedBox(height: 24),
                            ],

                            if (_filteredRutas.isNotEmpty) ...[
                              _buildSectionTitle("Rutas Populares", () {}),
                              const SizedBox(height: 16),
                              _buildHorizontalList(
                                data: _filteredRutas,
                                isRoute: true,
                              ),
                              const SizedBox(height: 24),
                            ],

                            if (_filteredLugares.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text(
                                  "Explora Más",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[900],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ..._filteredLugares.take(5).map((lugar) => 
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0, left: 20, right: 20),
                                  child: _buildLargePlaceCard(lugar),
                                )
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ubicación Actual",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    "Loja, Ecuador",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '¿A dónde quieres ir hoy?',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(Color primaryColor) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 10), // Add spacing from header
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1, // +1 for "Todos"
        itemBuilder: (context, index) {
          String categoryName;
          if (index == 0) {
            categoryName = "Todos";
          } else {
            categoryName = _categories[index - 1].nombre;
          }
          
          final isSelected = _selectedCategory == categoryName;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center( // Center vertically
              child: GestureDetector(
                onTap: () => _onCategorySelected(categoryName),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Slightly larger touch area
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(30), // Pill shape
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.grey[300]!,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    categoryName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[900],
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              "Ver Todos",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList({required List<dynamic> data, required bool isRoute}) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20.0),
        physics: const BouncingScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _buildSmallCard(data[index], isRoute);
        },
      ),
    );
  }

  Widget _buildSmallCard(dynamic item, bool isRoute) {
    String title = isRoute ? (item as Ruta).nombre : (item as Lugar).nombre;
    String subtitle = isRoute ? "${(item as Ruta).distanciaEstimadaKm} km" : ((item as Lugar).direccionCompleta ?? "Sin dirección");
    String? imageUrl = isRoute ? (item as Ruta).urlImagenPortada : (item as Lugar).urlImagenPrincipal;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (isRoute) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleRutaScreen(ruta: item as Ruta),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleLugarScreen(lugar: item as Lugar),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: isRoute ? 'ruta_${(item as Ruta).id}' : 'lugar_${(item as Lugar).id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey),
                          )
                        : Icon(
                            isRoute ? Icons.map_outlined : Icons.place,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isRoute ? Icons.directions_walk : Icons.location_on,
                          size: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
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
      ),
    );
  }

  Widget _buildLargePlaceCard(Lugar lugar) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetalleLugarScreen(lugar: lugar)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'lugar_large_${lugar.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Image.network(
                          lugar.urlImagenPrincipal ?? "https://via.placeholder.com/400x200",
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              const Icon(Icons.image, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (lugar.provincia != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lugar.provincia!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lugar.nombre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              "4.8",
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lugar.direccionCompleta ?? "Sin dirección",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No encontramos resultados",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Intenta con otra búsqueda o categoría",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
