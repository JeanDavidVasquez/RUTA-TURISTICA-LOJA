import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MisResenasScreen extends StatefulWidget {
  const MisResenasScreen({super.key});

  @override
  State<MisResenasScreen> createState() => _MisResenasScreenState();
}

class _MisResenasScreenState extends State<MisResenasScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    final userId = ApiService.currentUserId;
    if (userId != null) {
      setState(() {
        _futureReviews = _apiService.getReviews(userId, 'usuario');
      });
    } else {
      _futureReviews = Future.value([]);
    }
  }

  Future<void> _deleteReview(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Reseña"),
        content: const Text("¿Estás seguro de que quieres eliminar esta reseña?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Eliminar", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteReview(id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reseña eliminada")));
        _loadReviews();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _editReview(Map<String, dynamic> review) async {
    final TextEditingController commentController = TextEditingController(text: review['texto']);
    int rating = review['calificacion'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Editar Reseña"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setStateDialog(() => rating = index + 1);
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: "Escribe tu opinión...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await _apiService.updateReview(review['id'], rating, commentController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Reseña actualizada")),
                      );
                      _loadReviews();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Reseñas"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No has escrito reseñas aún."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final review = snapshot.data![index];
              final targetName = review['lugar_nombre'] ?? review['ruta_nombre'] ?? 'Desconocido';
              final isLugar = review['lugar'] != null;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(isLugar ? Icons.place : Icons.map, color: Colors.blue),
                      title: Text(targetName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(review['texto'] ?? ''),
                          const SizedBox(height: 4),
                          Text(
                            review['fechaCreacion']?.toString().split('T')[0] ?? '',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${review['calificacion']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                        ],
                      ),
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("Editar"),
                          onPressed: () => _editReview(review),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          label: const Text("Eliminar", style: TextStyle(color: Colors.red)),
                          onPressed: () => _deleteReview(review['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
