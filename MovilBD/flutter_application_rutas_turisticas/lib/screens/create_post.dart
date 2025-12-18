import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/lugar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _descController = TextEditingController();
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  // Lugar seleccionado
  Lugar? _selectedLugar;
  List<Lugar> _managedPlaces = [];
  bool _isLoadingPlaces = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _checkManagedPlaces();
  }

  Future<void> _checkManagedPlaces() async {
    if (ApiService.currentUserId == null) {
      if (mounted) setState(() => _isLoadingPlaces = false);
      return;
    }

    try {
      final places = await _apiService.getManagedPlaces(ApiService.currentUserId!);
      if (mounted) {
        setState(() {
          _managedPlaces = places;
          if (places.isNotEmpty) {
            _selectedLugar = places.first; // Pre-seleccionar el primero
          }
          _isLoadingPlaces = false;
        });
      }
    } catch (e) {
      print("Error loading managed places: $e");
      if (mounted) setState(() => _isLoadingPlaces = false);
    }
  }

  bool _isPickingImage = false; // Add this flag

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return; // Prevent multiple calls

    setState(() {
      _isPickingImage = true;
    });

    try {
      // Small delay to ensure UI is ready if triggered rapidly
      await Future.delayed(const Duration(milliseconds: 100));
      
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _submitPost() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una imagen')),
      );
      return;
    }
    if (_selectedLugar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor etiqueta un lugar')),
      );
      return;
    }
    if (ApiService.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      await _apiService.createPublicacion(
        usuarioId: ApiService.currentUserId!,
        lugarId: _selectedLugar!.id,
        descripcion: _descController.text,
        imageFile: _imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Publicación creada con éxito!')),
        );
        Navigator.pop(context); // Volver al feed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _showPlacePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height for search if needed
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Seleccionar Lugar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_managedPlaces.isNotEmpty) ...[
                const Text("Mis Lugares", style: TextStyle(color: Colors.grey)),
                Expanded(
                  child: ListView.builder(
                     shrinkWrap: true,
                     itemCount: _managedPlaces.length,
                     itemBuilder: (ctx, index) {
                       final lugar = _managedPlaces[index];
                       return ListTile(
                        leading: const Icon(Icons.business, color: Colors.purple),
                        title: Text(lugar.nombre),
                        onTap: () {
                          setState(() => _selectedLugar = lugar);
                          Navigator.pop(context);
                        },
                      );
                     }
                  ),
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("Buscar otro lugar..."),
                onTap: () async {
                   Navigator.pop(context);
                   _openSearchDialog();
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _openSearchDialog() async {
      try {
         final allPlaces = await _apiService.fetchLugares();
         if (!mounted) return;
         
         showDialog(context: context, builder: (ctx) {
           List<Lugar> filteredPlaces = List.from(allPlaces);
           
           return StatefulBuilder(
             builder: (context, setStateDialog) {
               return Dialog(
                 child: Container(
                   height: 500,
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     children: [
                       const Text("Buscar Lugar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                       const SizedBox(height: 10),
                       TextField(
                         autofocus: true,
                         decoration: InputDecoration(
                           hintText: "Escriba para filtrar...",
                           prefixIcon: const Icon(Icons.search),
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                           contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                         ),
                         onChanged: (value) {
                           setStateDialog(() {
                             final query = value.toLowerCase();
                             filteredPlaces = allPlaces.where((p) {
                               return p.nombre.toLowerCase().contains(query) ||
                                      (p.provincia?.toLowerCase().contains(query) ?? false) ||
                                      (p.canton?.toLowerCase().contains(query) ?? false);
                             }).toList();
                           });
                         },
                       ),
                       const SizedBox(height: 10),
                       Expanded(
                         child: filteredPlaces.isEmpty 
                           ? const Center(child: Text("No se encontraron lugares"))
                           : ListView.builder(
                             itemCount: filteredPlaces.length,
                             itemBuilder: (ctx, index) {
                               final p = filteredPlaces[index];
                               return ListTile(
                                 title: Text(p.nombre),
                                 subtitle: Text("${p.provincia ?? ''}, ${p.canton ?? ''}"),
                                 onTap: () {
                                   this.setState(() => _selectedLugar = p); // Use 'this.setState' to update parent widget
                                   Navigator.pop(ctx);
                                 },
                               );
                             },
                           ),
                       )
                     ],
                   ),
                 ),
               );
             }
           );
         });
      } catch(e) {
        print("Error fetching places: $e");
      }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPlaces) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Publicación'),
        actions: [
          IconButton(
            onPressed: _isPosting ? null : _submitPost,
            icon: _isPosting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.check),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Área de Imagen
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[200],
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Toca para añadir foto"),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Selector de Lugar
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: Text(_selectedLugar?.nombre ?? "Añadir Ubicación"),
              subtitle: _selectedLugar == null 
                  ? const Text("¿Dónde estás?") 
                  : Text(_managedPlaces.any((dl) => dl.id == _selectedLugar!.id) ? "Publicando como Administrador" : "Publicando como Visitante"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showPlacePicker,
            ),
            const Divider(),

            // Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: "Escribe un pie de foto...",
                  border: InputBorder.none,
                ),
                maxLines: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
