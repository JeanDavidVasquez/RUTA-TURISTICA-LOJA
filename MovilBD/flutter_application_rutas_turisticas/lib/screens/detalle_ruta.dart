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

  const DetalleRutaScreen({
    super.key,
    required this.ruta,
  });

  @override
  State<DetalleRutaScreen> createState() => _DetalleRutaScreenState();
}

class _DetalleRutaScreenState extends State<DetalleRutaScreen> {
  late Future<List<RutaLugar>> _futureRutaLugares;
  final ApiService _apiService = ApiService();
  bool _isSaved = false;
  bool _isCheckingStatus = true;
  bool _esMia = false;

  @override
  void initState() {
    super.initState();
    _futureRutaLugares = _apiService.fetchRutaLugares(widget.ruta.id);
    _checkStatus();
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
    // Optimistic update
    setState(() => _isSaved = !_isSaved);
    try {
      await _apiService.toggleGuardarRuta(widget.ruta.id, _isSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? "Ruta guardada en Mis Rutas" : "Ruta eliminada de Mis Rutas"),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Revert
      setState(() => _isSaved = !_isSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar: $e")),
      );
    }
  }

  void _navegarEditar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarRutaPage(ruta: widget.ruta),
      ),
    ).then((_) {
      // Refresh details if needed, or just pop back
      setState(() {
         // Force refresh of places
         _futureRutaLugares = _apiService.fetchRutaLugares(widget.ruta.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

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
                          errorBuilder: (c, e, s) => Container(color: Colors.grey),
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
                      _buildStatBadge(Icons.timer, "${widget.ruta.duracionEstimadaSeg ~/ 60} min"),
                      const SizedBox(width: 8),
                      _buildStatBadge(Icons.directions_walk, "${widget.ruta.distanciaEstimadaKm} km"),
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
                        "Paradas",
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
                          return _buildParadaItem(context, index, snapshot.data![index]);
                        },
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
                builder: (context) => Mapa(
                  ruta: widget.ruta,
                  startNavigation: true,
                ),
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
        // Create a partial Lugar object since we only have limited info here
        // Ideally we should fetch the full Lugar details
        Lugar partialLugar = Lugar(
          id: rutaLugar.lugar,
          nombre: rutaLugar.lugarNombre,
          descripcion: "Cargando detalles...",
          latitud: 0,
          longitud: 0,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetalleLugarScreen(lugar: partialLugar)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
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
                  Text(
                    "Punto de interés",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
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
