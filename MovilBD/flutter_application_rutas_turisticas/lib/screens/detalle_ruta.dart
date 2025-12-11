import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/details_places.dart';
import 'package:flutter_application_rutas_turisticas/screens/mapa.dart';
import 'package:flutter_application_rutas_turisticas/screens/editar_ruta.dart';
import '../models/ruta.dart';
import '../models/ruta_lugar.dart';
import '../models/lugar.dart';
import '../services/api_service.dart';

class DetalleRutaScreen extends StatefulWidget {
  final Ruta ruta;

  const DetalleRutaScreen({super.key, required this.ruta});

  @override
  State<DetalleRutaScreen> createState() => _DetalleRutaScreenState();
}

class _DetalleRutaScreenState extends State<DetalleRutaScreen> {
  late Future<List<RutaLugar>> _futureRutaLugares;
  final ApiService _apiService = ApiService();
  bool _isSaved = false;
  bool _isCheckingStatus = true;
  bool _esMia = false;

  // --- RESEÑAS ---
  List<dynamic> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _futureRutaLugares = _apiService.fetchRutaLugares(widget.ruta.id);
    _checkStatus();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await _apiService.getReviews(widget.ruta.id, 'ruta');
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loadingReviews = false;
        });
      }
    } catch (e) {
      print("Error loading reviews: $e");
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Future<void> _postReview() async {
    final TextEditingController commentController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Calificar Ruta"),
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
                      await _apiService.postReview(
                        widget.ruta.id,
                        'ruta',
                        rating,
                        commentController.text,
                      );
                      _loadReviews(); // Reload
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("¡Gracias por tu reseña!"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                  child: const Text("Publicar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _checkStatus() async {
    final currentUserId = ApiService.currentUserId;
    if (currentUserId != null) {
      setState(() {
        _esMia = widget.ruta.usuario == currentUserId;
      });

      if (!_esMia) {
        final saved = await _apiService.checkRutaGuardadaStatus(widget.ruta.id);
        if (mounted) {
          setState(() {
            _isSaved = saved;
            _isCheckingStatus = false;
          });
        }
      } else {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  Future<void> _toggleGuardar() async {
    setState(() => _isSaved = !_isSaved);
    try {
      await _apiService.toggleGuardarRuta(widget.ruta.id, _isSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved
                ? "Ruta guardada en Mis Rutas"
                : "Ruta eliminada de Mis Rutas",
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      setState(() => _isSaved = !_isSaved);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al actualizar: $e")));
    }
  }

  void _navegarEditar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarRutaPage(ruta: widget.ruta),
      ),
    ).then((_) {
      setState(() {
        _futureRutaLugares = _apiService.fetchRutaLugares(widget.ruta.id);
        _loadReviews();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    // Calcular tiempo total (estimado + paradas)
    int totalMinutos = widget.ruta.duracionEstimadaSeg ~/ 60;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.ruta.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.ruta.urlImagenPortada != null
                      ? Image.network(
                          widget.ruta.urlImagenPortada!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              Container(color: Colors.grey),
                        )
                      : Container(color: Colors.grey),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (!_isCheckingStatus)
                if (_esMia)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _navegarEditar,
                    tooltip: "Editar Ruta",
                  )
                else
                  IconButton(
                    icon: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    onPressed: _toggleGuardar,
                    tooltip: _isSaved ? "Dejar de seguir" : "Guardar Ruta",
                  ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Creado por",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            widget.ruta.usuarioUsername,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildStatBadge(Icons.timer, "$totalMinutos min"),
                      const SizedBox(width: 8),
                      _buildStatBadge(
                        Icons.directions_walk,
                        "${widget.ruta.distanciaEstimadaKm} km",
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Descripción",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ruta.descripcion,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Itinerario",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Mapa(ruta: widget.ruta),
                            ),
                          );
                        },
                        child: const Text("Ver en Mapa"),
                      ),
                    ],
                  ),

                  FutureBuilder<List<RutaLugar>>(
                    future: _futureRutaLugares,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("Esta ruta no tiene paradas aún.");
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return _buildParadaItem(
                            context,
                            index,
                            snapshot.data![index],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  // --- SECCIÓN DE RESEÑAS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Reseñas",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _postReview,
                        icon: const Icon(Icons.rate_review, size: 18),
                        label: const Text("Opinar"),
                      ),
                    ],
                  ),

                  if (_loadingReviews)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Sé el primero en opinar sobre esta ruta.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person, size: 16),
                          ),
                          title: Text(review['usuario_username'] ?? 'Usuario'),
                          subtitle: Text(review['texto'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${review['calificacion']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    Mapa(ruta: widget.ruta, startNavigation: true),
              ),
            );
          },
          icon: const Icon(Icons.navigation, color: Colors.white),
          label: const Text("Iniciar Ruta Ahora"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildParadaItem(
    BuildContext context,
    int index,
    RutaLugar rutaLugar,
  ) {
    return InkWell(
      onTap: () {
        Lugar partialLugar = Lugar(
          id: rutaLugar.lugar,
          nombre: rutaLugar.lugarNombre,
          descripcion: "Cargando detalles...",
          latitud: 0,
          longitud: 0,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleLugarScreen(lugar: partialLugar),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rutaLugar.lugarNombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (rutaLugar.tiempoSugeridoMinutos > 0)
                    Text(
                      "Tiempo sugerido: ${rutaLugar.tiempoSugeridoMinutos} min",
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (rutaLugar.comentario != null &&
                      rutaLugar.comentario!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        rutaLugar.comentario!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
