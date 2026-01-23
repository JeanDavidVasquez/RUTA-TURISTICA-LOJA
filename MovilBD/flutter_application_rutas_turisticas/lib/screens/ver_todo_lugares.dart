import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/lugar.dart';
import '../models/ubicacion.dart';
import 'details_places.dart';

class VerTodoLugaresScreen extends StatefulWidget {
  const VerTodoLugaresScreen({super.key});

  @override
  State<VerTodoLugaresScreen> createState() => _VerTodoLugaresScreenState();
}

class _VerTodoLugaresScreenState extends State<VerTodoLugaresScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  // State
  bool _isLoading = true;
  List<Lugar> _lugares = [];
  
  // Filtros
  List<Provincia> _provincias = [];
  List<Canton> _cantones = [];
  List<Parroquia> _parroquias = [];
  
  Provincia? _selectedProvincia;
  Canton? _selectedCanton;
  Parroquia? _selectedParroquia;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _apiService.fetchLugares(),
        _apiService.fetchProvincias(),
      ]);
      
      if (mounted) {
        setState(() {
          _lugares = results[0] as List<Lugar>;
          _provincias = results[1] as List<Provincia>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }
  
  Future<void> _onProvinciaChanged(Provincia? provincia) async {
    setState(() {
      _selectedProvincia = provincia;
      _selectedCanton = null;
      _selectedParroquia = null;
      _cantones = [];
      _parroquias = [];
    });
    
    if (provincia != null) {
      try {
        final cantones = await _apiService.fetchCantones(provinciaNombre: provincia.nombre);
        if (mounted) {
          setState(() => _cantones = cantones);
        }
      } catch (e) {
        print("Error loading cantones: $e");
      }
    }
    
    _applyFilters();
  }
  
  Future<void> _onCantonChanged(Canton? canton) async {
    setState(() {
      _selectedCanton = canton;
      _selectedParroquia = null;
      _parroquias = [];
    });
    
    if (canton != null) {
      try {
        final parroquias = await _apiService.fetchParroquias(cantonNombre: canton.nombre);
        if (mounted) {
          setState(() => _parroquias = parroquias);
        }
      } catch (e) {
        print("Error loading parroquias: $e");
      }
    }
    
    _applyFilters();
  }
  
  void _onParroquiaChanged(Parroquia? parroquia) {
    setState(() => _selectedParroquia = parroquia);
    _applyFilters();
  }
  
  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);
    
    try {
      final lugares = await _apiService.fetchLugaresFiltrados(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        provincia: _selectedProvincia?.nombre,
        canton: _selectedCanton?.nombre,
        parroquia: _selectedParroquia?.nombre,
      );
      
      if (mounted) {
        setState(() {
          _lugares = lugares;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error applying filters: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _clearFilters() {
    setState(() {
      _selectedProvincia = null;
      _selectedCanton = null;
      _selectedParroquia = null;
      _cantones = [];
      _parroquias = [];
      _searchController.clear();
      _searchQuery = '';
    });
    _loadInitialData();
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
          "Explorar Lugares",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedProvincia != null || _searchQuery.isNotEmpty)
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
                    if (value.length > 2 || value.isEmpty) {
                      _applyFilters();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Buscar lugar...",
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
                
                // Filtros en cascada
                Row(
                  children: [
                    // Provincia
                    Expanded(
                      child: _buildDropdown<Provincia>(
                        value: _selectedProvincia,
                        items: _provincias,
                        hint: "Provincia",
                        onChanged: _onProvinciaChanged,
                        getLabel: (p) => p.nombre,
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Cantón
                    Expanded(
                      child: _buildDropdown<Canton>(
                        value: _selectedCanton,
                        items: _cantones,
                        hint: "Cantón",
                        onChanged: _onCantonChanged,
                        getLabel: (c) => c.nombre,
                        enabled: _selectedProvincia != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Parroquia (full width)
                _buildDropdown<Parroquia>(
                  value: _selectedParroquia,
                  items: _parroquias,
                  hint: "Parroquia",
                  onChanged: _onParroquiaChanged,
                  getLabel: (p) => p.nombre,
                  enabled: _selectedCanton != null,
                ),
              ],
            ),
          ),
          
          // Contador de resultados
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "${_lugares.length} lugares encontrados",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          
          // Lista de lugares
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _lugares.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _lugares.length,
                        itemBuilder: (context, index) => _buildLugarCard(_lugares[index]),
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required void Function(T?) onChanged,
    required String Function(T) getLabel,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(getLabel(item), style: const TextStyle(fontSize: 14)),
          )).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No se encontraron lugares",
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
  
  Widget _buildLugarCard(Lugar lugar) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleLugarScreen(lugar: lugar),
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: lugar.urlImagenPrincipal != null
                      ? Image.network(
                          lugar.urlImagenPrincipal!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => 
                              Icon(Icons.image, size: 40, color: Colors.grey[400]),
                        )
                      : Icon(Icons.image, size: 40, color: Colors.grey[400]),
                ),
              ),
            ),
            
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
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
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          lugar.ratingPromedio > 0 
                              ? lugar.ratingPromedio.toStringAsFixed(1) 
                              : "Nuevo",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: lugar.ratingPromedio > 0 ? Colors.black : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lugar.provincia ?? 'Ecuador',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
