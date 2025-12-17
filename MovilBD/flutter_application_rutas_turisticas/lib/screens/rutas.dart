import 'package:flutter/material.dart';
import 'package:flutter_application_rutas_turisticas/screens/editar_ruta.dart';
import 'package:flutter_application_rutas_turisticas/screens/detalle_ruta.dart';
import 'package:flutter_application_rutas_turisticas/screens/mapa.dart';
import '../services/api_service.dart';
import '../models/ruta.dart';

class Rutas extends StatefulWidget {
  const Rutas({super.key});

  @override
  State<Rutas> createState() => _RutasState();
}

class _RutasState extends State<Rutas> {
  // --- LÓGICA DEL MODAL PARA CREAR RUTA ---
  void _mostrarModalCrearRuta(BuildContext context) {
    final TextEditingController nombreRutaController = TextEditingController();
    final Color primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Nueva Aventura",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ponle un nombre genial a tu ruta para empezar.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: nombreRutaController,
                  autofocus: true,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: "Ej: Caminata al atardecer",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.edit_location_alt, color: primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (nombreRutaController.text.trim().isNotEmpty) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarRutaPage(
                            nombreInicial: nombreRutaController.text,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Crear Ruta",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA), // Fondo gris suave moderno
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _mostrarModalCrearRuta(context),
          backgroundColor: Colors.black87, // Botón negro elegante
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text("Crear Ruta", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header personalizado
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Explorar Rutas",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: primaryColor,
                        unselectedLabelColor: Colors.grey[500],
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        dividerColor: Colors.transparent,
                        padding: const EdgeInsets.all(4),
                        tabs: const [
                          Tab(text: 'Mis Rutas'),
                          Tab(text: 'Descubrir'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _RutasList(tipo: 'MIS_RUTAS'),
                    _RutasList(tipo: 'DESCUBRIR'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RutasList extends StatefulWidget {
  final String tipo; // 'MIS_RUTAS' o 'DESCUBRIR'
  const _RutasList({required this.tipo});

  @override
  State<_RutasList> createState() => _RutasListState();
}

class _RutasListState extends State<_RutasList> {
  final ApiService apiService = ApiService();
  late Future<List<Ruta>> futureRutas;
  String _filtroSeleccionado = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadRutas();
  }

  void _loadRutas() {
    setState(() {
      if (widget.tipo == 'MIS_RUTAS') {
        futureRutas = _fetchMisRutasCombined();
      } else {
        futureRutas = apiService.fetchRutas();
      }
    });
  }

  Future<List<Ruta>> _fetchMisRutasCombined() async {
    final currentUserId = ApiService.currentUserId;
    if (currentUserId == null) return [];

    final allRutas = await apiService.fetchRutas();
    final myCreatedRutas = allRutas.where((r) => r.usuario == currentUserId).toList();
    final savedRutas = await apiService.fetchRutasGuardadas();

    final Map<int, Ruta> combinedMap = {};
    for (var r in myCreatedRutas) combinedMap[r.id] = r;
    for (var r in savedRutas) combinedMap[r.id] = r;

    return combinedMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.tipo == 'DESCUBRIR')
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildFilterChip('Todas'),
                const SizedBox(width: 10),
                _buildFilterChip('Populares'),
                const SizedBox(width: 10),
                _buildFilterChip('Nuevas'),
              ],
            ),
          ),

        Expanded(
          child: FutureBuilder<List<Ruta>>(
            future: futureRutas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
              } else if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              List<Ruta> rutasFiltradas = snapshot.data!;
              if (widget.tipo == 'DESCUBRIR') {
                rutasFiltradas = rutasFiltradas.where((r) => r.visibilidadRuta == 'publica').toList();
                if (_filtroSeleccionado == 'Populares') {
                  rutasFiltradas.sort((a, b) => b.numGuardados.compareTo(a.numGuardados));
                }
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: rutasFiltradas.length,
                separatorBuilder: (c, i) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final ruta = rutasFiltradas[index];
                  final esMia = ruta.usuario == ApiService.currentUserId;
                  return _ModernRutaCard(
                    ruta: ruta,
                    esMia: esMia,
                    onUpdate: _loadRutas,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filtroSeleccionado == label;
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => setState(() => _filtroSeleccionado = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.tipo == 'MIS_RUTAS' ? Icons.map_outlined : Icons.explore_off_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.tipo == 'MIS_RUTAS' ? "Sin rutas guardadas" : "No hay rutas públicas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            "Empieza creando tu primera aventura",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text("Ocurrió un error: $error", textAlign: TextAlign.center),
      ),
    );
  }
}
class _ModernRutaCard extends StatelessWidget {
  final Ruta ruta;
  final bool esMia;
  final VoidCallback onUpdate;

  const _ModernRutaCard({
    required this.ruta,
    required this.esMia,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos imagen de portada si existe, si no, un placeholder visual
    final hasImage = ruta.urlImagenPortada != null && ruta.urlImagenPortada!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetalleRutaScreen(ruta: ruta)),
            ).then((_) => onUpdate());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN IMAGEN (Estilo Airbnb/Temu) ---
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: hasImage
                          ? Image.network(
                        ruta.urlImagenPortada!,
                        fit: BoxFit.cover,
                        errorBuilder: (c,e,s) => _buildPlaceholderImage(),
                      )
                          : _buildPlaceholderImage(),
                    ),
                  ),
                  // Badge Pública/Privada
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ruta.visibilidadRuta == 'publica' ? Icons.public : Icons.lock_outline,
                            size: 12,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ruta.visibilidadRuta == 'publica' ? "Pública" : "Privada",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // --- SECCIÓN INFO ---
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            ruta.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (ruta.numGuardados > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.favorite, size: 14, color: Colors.red[400]),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (!esMia)
                      Text(
                        "Creado por ${ruta.usuarioUsername}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),

                    const SizedBox(height: 16),

                    // Métricas
                    Row(
                      children: [
                        _buildMetricBadge(
                          Icons.timer_outlined,
                          "${ruta.duracionEstimadaSeg ~/ 60} min",
                          Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildMetricBadge(
                          Icons.directions_walk,
                          "${ruta.distanciaEstimadaKm} km",
                          Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- BOTONES DE ACCIÓN ---
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Mapa(ruta: ruta)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Iniciar Ruta", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        if (esMia) ...[
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditarRutaPage(ruta: ruta),
                                ),
                              ).then((_) => onUpdate());
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: const Icon(Icons.edit_outlined, color: Colors.black87, size: 20),
                            ),
                          ),
                        ]
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text("Ver Mapa", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}