import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/agregar_lugar_ruta.dart';
import '../models/ruta.dart';
import '../models/lugar.dart';
import '../models/categoria.dart';
import '../services/api_service.dart';

class EditarRutaPage extends StatefulWidget {
  final Ruta? ruta; // Ruta existente para editar, o null para crear
  final String? nombreInicial; // Para cuando venimos del modal rápido

  const EditarRutaPage({super.key, this.ruta, this.nombreInicial});

  @override
  State<EditarRutaPage> createState() => _EditarRutaPageState();
}

class _EditarRutaPageState extends State<EditarRutaPage> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  
  // Categorías
  List<Categoria> _categoriasDisponibles = [];
  Categoria? _selectedCategory;
  bool _isLoadingCategorias = true;

  bool _isPublic = true;
  List<Lugar> _puntosRuta = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.ruta?.nombre ?? widget.nombreInicial ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.ruta?.descripcion ?? '',
    );
    _isPublic = widget.ruta?.visibilidadRuta == 'publica';

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      // 1. Cargar categorías
      final categorias = await apiService.fetchCategorias();
      
      // 2. Cargar todos los lugares (necesario para mapear IDs a objetos)
      final todosLosLugares = await apiService.fetchLugares();

      // 3. Si es edición, cargar lugares de la ruta
      if (widget.ruta != null) {
        final rutaLugares = await apiService.fetchRutaLugares(widget.ruta!.id);
        
        // Mapear IDs de RutaLugar a objetos Lugar completos
        _puntosRuta = rutaLugares.map((rl) {
          try {
            return todosLosLugares.firstWhere((l) => l.id == rl.lugar);
          } catch (e) {
            // Si no se encuentra (caso raro), retornamos un lugar dummy o lo omitimos
            // Para seguridad, filtramos nulos después si fuera necesario, pero firstWhere lanza excepción
            return null; 
          }
        }).whereType<Lugar>().toList(); // Filtramos los nulos si hubo error
      }

      setState(() {
        _categoriasDisponibles = categorias;
        _isLoadingCategorias = false;
        
        // Seleccionar categoría inicial si estamos editando
        if (widget.ruta != null && widget.ruta!.categorias.isNotEmpty) {
          // Buscamos la categoría que coincida por ID
          try {
            _selectedCategory = categorias.firstWhere(
              (c) => c.id == widget.ruta!.categorias.first.id
            );
          } catch (e) {
            // Si no se encuentra, dejamos null o la primera
            if (categorias.isNotEmpty) _selectedCategory = categorias.first;
          }
        } else if (categorias.isNotEmpty) {
          _selectedCategory = categorias.first;
        }
      });
    } catch (e) {
      print("Error loading initial data: $e");
      setState(() => _isLoadingCategorias = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardarRuta() async {
    if (!_formKey.currentState!.validate()) return;
    if (ApiService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no identificado')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final rutaData = {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'visibilidadRuta': _isPublic ? 'publica' : 'privada',
        'usuario': ApiService.currentUserId,
        'duracionEstimadaSeg': 3600, // Valor por defecto o calculado
        'distanciaEstimadaKm': 5.0, // Valor por defecto o calculado
        // Categorías: enviamos una lista con el ID de la seleccionada
        'categorias': _selectedCategory != null ? [_selectedCategory!.id] : [],
      };

      Ruta rutaGuardada;
      if (widget.ruta != null) {
        // Actualizar
        rutaGuardada = await apiService.updateRuta(widget.ruta!.id, rutaData);
        
        // Actualizar lugares:
        // Estrategia simple: Borrar todos los lugares existentes y añadir los nuevos.
        // 1. Obtener lugares actuales
        final currentRutaLugares = await apiService.fetchRutaLugares(rutaGuardada.id);
        // 2. Borrarlos
        for (var rl in currentRutaLugares) {
          await apiService.removeLugarFromRuta(rl.id);
        }
      } else {
        // Crear
        rutaGuardada = await apiService.createRuta(rutaData);
      }

      // Añadir lugares (para crear y actualizar)
      for (int i = 0; i < _puntosRuta.length; i++) {
        await apiService.addLugarToRuta(rutaGuardada.id, _puntosRuta[i].id, i);
      }

      if (mounted) {
        Navigator.pop(context, true); // Retornar true para indicar éxito
      }
    } catch (e) {
      print("Error saving ruta: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _eliminarRuta() async {
    if (widget.ruta == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Ruta"),
        content: const Text("¿Estás seguro de que quieres eliminar esta ruta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await apiService.deleteRuta(widget.ruta!.id);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        print("Error deleting ruta: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    
    if (_isLoadingCategorias) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.ruta != null ? "Editar Ruta" : "Crear Ruta",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _guardarRuta,
              child: Text(
                "Guardar",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detalles de la Ruta",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("Nombre", style: TextStyle(fontWeight: FontWeight.w600)),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  hintText: "Ej: Ruta por el centro",
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                "Descripción",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  hintText: "Describe tu ruta...",
                ),
                maxLines: 4,
                validator: (value) =>
                    value == null || value.isEmpty ? 'La descripción es requerida' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                "Categoría",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              DropdownButtonFormField<Categoria>(
                value: _selectedCategory,
                items: _categoriasDisponibles
                    .map(
                      (Categoria category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.nombre),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedCategory = newValue),
                decoration: const InputDecoration(),
                hint: const Text("Selecciona una categoría"),
              ),
              const SizedBox(height: 16),
              const Text(
                "Visibilidad",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildVisibilityButton(
                      context,
                      Icons.lock_outline,
                      "Privada",
                      !_isPublic,
                      () => setState(() => _isPublic = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildVisibilityButton(
                      context,
                      Icons.visibility_outlined,
                      "Pública",
                      _isPublic,
                      () => setState(() => _isPublic = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Puntos de la Ruta",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${_puntosRuta.length} lugares",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_puntosRuta.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Text(
                      "Aún no has añadido lugares.",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _puntosRuta.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final Lugar item = _puntosRuta.removeAt(oldIndex);
                      _puntosRuta.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) => _buildPuntoItem(
                    index,
                    _puntosRuta[index],
                    () => setState(() => _puntosRuta.removeAt(index)),
                  ),
                ),
              const SizedBox(height: 16),

              // BOTÓN AÑADIR LUGAR
              ElevatedButton.icon(
                onPressed: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AgregarLugarScreen(),
                    ),
                  );
                  if (resultado != null && resultado is Lugar) {
                    setState(() => _puntosRuta.add(resultado));
                  }
                },
                icon: Icon(Icons.add, color: primaryColor),
                label: Text(
                  "Añadir Lugar",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.withOpacity(0.1),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (widget.ruta != null)
                Center(
                  child: TextButton.icon(
                    onPressed: _eliminarRuta,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Eliminar Ruta"),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityButton(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onPressed,
  ) {
    final Color color = Theme.of(context).primaryColor;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: isActive ? color : Colors.grey[700]),
      label: Text(
        label,
        style: TextStyle(
          color: isActive ? color : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: isActive ? color.withOpacity(0.1) : Colors.white,
        side: BorderSide(color: isActive ? color : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildPuntoItem(int index, Lugar lugar, VoidCallback onDelete) {
    return Container(
      key: ValueKey(lugar.id), // Importante para ReorderableListView
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: const Icon(Icons.drag_handle, color: Colors.grey),
        title: Text(
          "${index + 1}. ${lugar.nombre}",
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
