import 'package:flutter/material.dart';
import '../models/publicacion.dart';
import '../services/api_service.dart';
import 'details_places.dart';
import '../models/comentario.dart';

class PostDetailScreen extends StatefulWidget {
  final Publicacion post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentController = TextEditingController();
  
  List<Comentario> _comentarios = [];
  bool _loadingComments = true;

  @override
  void initState() {
    super.initState();
    _loadComentarios();
  }

  Future<void> _loadComentarios() async {
    try {
      final comments = await _apiService.fetchComentarios(widget.post.id);
      if (mounted) {
        setState(() {
          _comentarios = comments;
          _loadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingComments = false);
      print("Error loading comments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logic: If user is owner, explicitly show "Propietario"
    final bool isOwner = widget.post.esPropietario;
    final roleLabel = isOwner ? "Propietario" : "Turista";
    final roleColor = isOwner ? Colors.purple : Colors.blue;

    final bool isMyPost = ApiService.currentUserId == widget.post.usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Publicación"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isMyPost)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _showEditDialog();
                if (value == 'delete') _confirmDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Editar")),
                const PopupMenuItem(value: 'delete', child: Text("Eliminar", style: TextStyle(color: Colors.red))),
              ],
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: widget.post.usuarioFoto != null
                          ? NetworkImage(widget.post.usuarioFoto!)
                          : null,
                      child: widget.post.usuarioFoto == null
                          ? Text(widget.post.usuarioUsername[0].toUpperCase())
                          : null,
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(widget.post.usuarioUsername,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                           final lugar = await _apiService.getLugar(widget.post.lugar);
                           if (mounted) {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (_) => DetalleLugarScreen(lugar: lugar))
                             );
                           }
                        } catch(e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                        }
                      },
                      child: Text("📍 ${widget.post.lugarNombre}",
                         style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                    ),
                  ),

                  // --- IMAGEN ---
                  if (widget.post.archivoMedia != null)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: Image.network(
                        _apiService.getImageUrl(widget.post.archivoMedia)!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(
                              child: Text("No se pudo cargar la imagen")),
                        ),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 300,
                            color: Colors.grey[100],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),

                  // --- DESCRIPCIÓN ---
                  if (widget.post.descripcion != null &&
                      widget.post.descripcion!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        widget.post.descripcion!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                  const Divider(),

                  // --- SECCIÓN DE COMENTARIOS (Simulada) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const Text(
                      "Comentarios",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  
                  _loadingComments 
                    ? const Center(child: CircularProgressIndicator())
                    : _comentarios.isEmpty 
                      ? const Padding(padding: EdgeInsets.all(16), child: Text("Sé el primero en comentar"))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comentarios.length,
                          itemBuilder: (context, index) {
                            final comment = _comentarios[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundImage: comment.usuarioFoto != null ? NetworkImage(comment.usuarioFoto!) : null,
                                child: comment.usuarioFoto == null ? const Icon(Icons.person, size: 16) : null,
                              ),
                              title: Text(comment.usuarioUsername, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Text(comment.texto),
                              dense: true,
                            );
                          },
                        ),
                ],
              ),
            ),
          ),

          // --- INPUT COMENTARIO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Añadir un comentario...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    if (_commentController.text.trim().isEmpty) return;
                    
                    if (ApiService.currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Debes iniciar sesión para comentar")));
                      return;
                    }

                    try {
                      await _apiService.createComentario(
                        ApiService.currentUserId!, 
                        widget.post.id, 
                        _commentController.text
                      );
                      _commentController.clear();
                      _loadComentarios(); // Reload to show new comment
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar publicación"),
        content: const Text("¿Estás seguro de que quieres eliminar esta publicación?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            try {
              await _apiService.deletePublicacion(widget.post.id);
              if (mounted) {
                Navigator.pop(context); // Close detail screen
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            }
          }, child: const Text("Eliminar", style: TextStyle(color: Colors.red))),
        ],
      )
    );
  }

  void _showEditDialog() {
    final TextEditingController editController = TextEditingController(text: widget.post.descripcion);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar publicación"),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: "Descripción"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            try {
              // We only implement updating description for now
              await _apiService.updatePublicacion(widget.post.id, {"descripcion": editController.text});
              // Force reload or just update UI? For simplicity, close screen or show message. 
              // Better: Refresh current screen? We passed 'post' object which is immutable.
              // Easier: Pop and refresh feed. 
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Publicación actualizada")));
                Navigator.pop(context); // Close detail, back to feed
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            }
          }, child: const Text("Guardar")),
        ],
      )
    );
  }
}
