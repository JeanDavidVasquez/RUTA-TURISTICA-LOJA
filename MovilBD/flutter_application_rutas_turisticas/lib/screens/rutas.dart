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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Agregar Ruta",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Ponle un nombre a tu nueva ruta para empezar a agregar lugares.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Nombre de la ruta",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: nombreRutaController,
                    decoration: InputDecoration(
                      hintText: "Ej: Mi ruta del fin de semana",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarRutaPage(
                                nombreInicial: nombreRutaController.text,
                              ),
                            ),
                          ).then((_) => setState(() {})); // Recargar al volver
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Crear y agregar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () => _mostrarModalCrearRuta(context),
          backgroundColor: primaryColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Rutas",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            TabBar(
              indicatorColor: primaryColor,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              tabs: const [
                Tab(text: 'Mis Rutas'),
                Tab(text: 'Descubrir'),
              ],
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
  String _filtroSeleccionado = 'Todas'; // 'Todas', 'Populares'

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
        // Filtros solo para Descubrir
        if (widget.tipo == 'DESCUBRIR')
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todas'),
                const SizedBox(width: 8),
                _buildFilterChip('Populares'),
              ],
            ),
          ),

        Expanded(
          child: FutureBuilder<List<Ruta>>(
            future: futureRutas,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              List<Ruta> rutasFiltradas = snapshot.data!;

              if (widget.tipo == 'DESCUBRIR') {
                rutasFiltradas = rutasFiltradas
                    .where((r) => r.visibilidadRuta == 'publica')
                    .toList();
                
                if (_filtroSeleccionado == 'Populares') {
                  rutasFiltradas.sort((a, b) => b.numGuardados.compareTo(a.numGuardados));
                }
              }

              if (rutasFiltradas.isEmpty) {
                return const Center(child: Text("No se encontraron rutas."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rutasFiltradas.length,
                itemBuilder: (context, index) {
                  final ruta = rutasFiltradas[index];
                  final esMia = ruta.usuario == ApiService.currentUserId;
                  
                  return _RutaCard(
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _filtroSeleccionado = label;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.tipo == 'MIS_RUTAS' ? Icons.map : Icons.public,
            size: 50,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            widget.tipo == 'MIS_RUTAS'
                ? "No tienes rutas creadas ni guardadas."
                : "No hay rutas públicas disponibles.",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _RutaCard extends StatelessWidget {
  final Ruta ruta;
  final bool esMia;
  final VoidCallback onUpdate;

  const _RutaCard({
    required this.ruta,
    required this.esMia,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navegar al detalle
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleRutaScreen(ruta: ruta),
            ),
          ).then((_) => onUpdate());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ruta.nombre,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!esMia)
                          Text(
                            "por ${ruta.usuarioUsername}",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  if (ruta.visibilidadRuta == 'publica')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "Pública",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoIconText(
                      icon: Icons.schedule,
                      text: "${ruta.duracionEstimadaSeg ~/ 60} min"),
                  const SizedBox(width: 16),
                  _InfoIconText(
                      icon: Icons.location_on_outlined,
                      text: "${ruta.distanciaEstimadaKm} km"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // --- BOTÓN INICIAR ---
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Mapa(ruta: ruta),
                          ),
                        );
                      },
                      icon: const Icon(Icons.navigation,
                          size: 18, color: Colors.white),
                      label: const Text('Iniciar',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // --- BOTÓN EDITAR (Solo si es mía) ---
                  if (esMia)
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditarRutaPage(
                              ruta: ruta, // Pass the full route object
                            ),
                          ),
                        ).then((_) => onUpdate());
                      },
                      icon: const Icon(Icons.edit_outlined),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoIconText extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoIconText({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 18),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }
}
