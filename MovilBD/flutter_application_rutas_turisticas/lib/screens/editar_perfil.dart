import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Usuario usuario;

  const EditarPerfilScreen({super.key, required this.usuario});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _fotoController;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.usuario.nombreDisplay);
    _fotoController = TextEditingController(text: widget.usuario.urlFotoPerfil);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.updateProfile(widget.usuario.id, {
        'nombreDisplay': _nombreController.text,
        'varFoto': _fotoController.text.isNotEmpty ? _fotoController.text : null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pop(context, true); // Retorna true para indicar que hubo cambios
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Preview de la foto
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _fotoController.text.isNotEmpty
                      ? NetworkImage(_fotoController.text)
                      : (widget.usuario.urlFotoPerfil != null
                          ? NetworkImage(widget.usuario.urlFotoPerfil!)
                          : null),
                  child: (_fotoController.text.isEmpty && widget.usuario.urlFotoPerfil == null)
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre para mostrar",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _fotoController,
                decoration: InputDecoration(
                  labelText: "URL de Foto de Perfil",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.image_outlined),
                  helperText: "Pega el enlace de una imagen de internet",
                ),
                onChanged: (val) => setState(() {}), // Para actualizar el preview
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Guardar Cambios",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
