import 'package:flutter/material.dart';
import '../models/lugar.dart';
import '../models/categoria.dart';
import '../services/api_service.dart';

class AgregarLugarScreen extends StatefulWidget {
  const AgregarLugarScreen({super.key});
  @override
  State<AgregarLugarScreen> createState() => _AgregarLugarScreenState();
}

class _AgregarLugarScreenState extends State<AgregarLugarScreen> {
  final ApiService apiService = ApiService();
  List<Lugar> _todosLosLugares = [];
  List<Lugar> _lugaresFiltrados = [];
  List<Categoria> _categorias = [];
  bool _isLoading = true;

  String _filtroTexto = "";
  String _filtroCategoria = "Todos";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final lugares = await apiService.fetchLugares();
      final categorias = await apiService.fetchCategorias();
      setState(() {
        _todosLosLugares = lugares;
        _lugaresFiltrados = lugares;
        _categorias = categorias;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _lugaresFiltrados = _todosLosLugares.where((lugar) {
        final coincideTexto = lugar.nombre.toLowerCase().contains(
          _filtroTexto.toLowerCase(),
        );
        // Filtro simple por nombre de categoría (asumiendo que lugar tiene lista de categorías)
        // Si _filtroCategoria es "Todos", pasa. Si no, revisamos si alguna categoría del lugar coincide.
        final coincideCategoria = _filtroCategoria == "Todos" ||
            lugar.categorias.any((c) => c.nombre == _filtroCategoria);
            
        return coincideTexto && coincideCategoria;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Añadir Lugar a Ruta",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buscador
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        _filtroTexto = value;
                        _aplicarFiltros();
                      },
                      decoration: const InputDecoration(
                        hintText: "Buscar un lugar...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      _buildCategoryChip("Todos", primaryColor),
                      ..._categorias.map((c) => _buildCategoryChip(c.nombre, primaryColor)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Lugares Disponibles",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Lista
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _lugaresFiltrados.length,
                    itemBuilder: (context, index) {
                      return _buildLugarItem(context, _lugaresFiltrados[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChip(String label, Color primaryColor) {
    final isSelected = _filtroCategoria == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filtroCategoria = selected ? label : "Todos";
            _aplicarFiltros();
          });
        },
        selectedColor: primaryColor.withOpacity(0.2),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? primaryColor : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildLugarItem(BuildContext context, Lugar lugar) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pop(context, lugar), // Retorna el objeto Lugar
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: lugar.urlImagenPrincipal != null &&
                            lugar.urlImagenPrincipal!.isNotEmpty
                        ? Image.network(
                            lugar.urlImagenPrincipal!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.image, color: Colors.grey),
                          )
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lugar.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lugar.categorias.isNotEmpty
                            ? lugar.categorias.first.nombre
                            : 'Sin categoría',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, lugar),
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: primaryColor,
                    size: 32,
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
