import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/ruta.dart';
import '../models/categoria.dart';
import 'detalle_ruta.dart';

class VerTodoRutasScreen extends StatefulWidget {
  const VerTodoRutasScreen({super.key});

  @override
  State<VerTodoRutasScreen> createState() => _VerTodoRutasScreenState();
}

class _VerTodoRutasScreenState extends State<VerTodoRutasScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<Ruta> _allRutas = [];
  List<Ruta> _filteredRutas = [];
  List<Categoria> _categorias = [];
  
  String _searchQuery = '';
  Categoria? _selectedCategoria;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _apiService.fetchRutas(),
        _apiService.fetchCategorias(),
      ]);
      
      if (mounted) {
        setState(() {
          _allRutas = results[0] as List<Ruta>;
          _filteredRutas = _allRutas;
          _categorias = results[1] as List<Categoria>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando rutas: $e')),
        );
      }
    }
  }
  
  void _applyFilters() {
    setState(() {
      _filteredRutas = _allRutas.where((ruta) {
        // Filtro por búsqueda de texto
        final matchesSearch = _searchQuery.isEmpty ||
            ruta.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (ruta.descripcion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        // Filtro por categoría
        final matchesCategoria = _selectedCategoria == null ||
            ruta.categorias.any((c) => c.id == _selectedCategoria!.id);
        
        return matchesSearch && matchesCategoria;
      }).toList();
    });
  }
  
  void _clearFilters() {
    setState(() {
      _selectedCategoria = null;
      _searchController.clear();
      _searchQuery = '';
      _filteredRutas = _allRutas;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Explorar Rutas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedCategoria != null || _searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text("Limpiar"),
            ),
        ],
      ),
      body: Column(
        children: [
          // Buscador y Filtros
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Buscador
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: "Buscar ruta...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filtro por categoría
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Categoria>(
                      value: _selectedCategoria,
                      hint: const Text("Todas las categorías"),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      items: [
                        const DropdownMenuItem<Categoria>(
                          value: null,
                          child: Text("Todas las categorías"),
                        ),
                        ..._categorias.map((cat) => DropdownMenuItem<Categoria>(
                          value: cat,
                          child: Text(cat.nombre),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategoria = value);
                        _applyFilters();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contador de resultados
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "${_filteredRutas.length} rutas encontradas",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          
          // Lista de rutas
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _filteredRutas.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRutas.length,
                        itemBuilder: (context, index) => _buildRutaCard(_filteredRutas[index]),
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No se encontraron rutas",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            "Intenta con otros filtros",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRutaCard(Ruta ruta) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleRutaScreen(ruta: ruta),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: ruta.urlImagenPortada != null
                    ? Image.network(
                        ruta.urlImagenPortada!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => 
                            Icon(Icons.route, size: 40, color: Colors.grey[400]),
                      )
                    : Icon(Icons.route, size: 40, color: Colors.grey[400]),
              ),
            ),
            
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ruta.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (ruta.categorias.isNotEmpty)
                      Text(
                        ruta.categorias.map((c) => c.nombre).join(", "),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          "${(ruta.duracionEstimadaSeg / 60).round()} min",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.straighten, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          "${double.tryParse(ruta.distanciaEstimadaKm)?.toStringAsFixed(1) ?? ruta.distanciaEstimadaKm} km",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Flecha
            Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.chevron_right, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
