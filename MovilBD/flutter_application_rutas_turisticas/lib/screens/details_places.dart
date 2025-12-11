import 'package:flutter/material.dart';

import 'package:flutter_application_rutas_turisticas/screens/mapa.dart';
import '../models/lugar.dart';
import '../services/api_service.dart';

class DetalleLugarScreen extends StatefulWidget {
  final Lugar lugar;

  const DetalleLugarScreen({super.key, required this.lugar});

  @override
  State<DetalleLugarScreen> createState() => _DetalleLugarScreenState();
}

class _DetalleLugarScreenState extends State<DetalleLugarScreen> {
  final ApiService _apiService = ApiService();
  
  // Estados locales
  bool _isFavorito = false;
  bool _isPendiente = false;
  bool _isVisitado = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final status = await _apiService.checkFavoritoStatus(widget.lugar.id);
      if (mounted) {
        setState(() {
          _isFavorito = status['FAV'] ?? false;
          _isPendiente = status['PEND'] ?? false;
          _isVisitado = status['VISIT'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error checking status: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(String tipo, bool isActive) async {
    // Optimistic update
    setState(() {
      if (tipo == 'FAV') _isFavorito = isActive;
      if (tipo == 'PEND') _isPendiente = isActive;
      if (tipo == 'VISIT') _isVisitado = isActive;
    });

    try {
      await _apiService.toggleFavorito(widget.lugar.id, tipo, isActive);
    } catch (e) {
      // Revert if error
      print("Error toggling status: $e");
      if (mounted) {
        setState(() {
          if (tipo == 'FAV') _isFavorito = !isActive;
          if (tipo == 'PEND') _isPendiente = !isActive;
          if (tipo == 'VISIT') _isVisitado = !isActive;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $e")),
        );
      }
    }
  }



  // --- MÉTODO: MENU DE LISTAS (Bottom Sheet) ---
  void _mostrarOpcionesGuardado(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Usamos StatefulBuilder para que los switches se muevan sin cerrar el modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Gestionar Listas",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Agrega este lugar a tus listas personales.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Opción 1: Favoritos
                  ListTile(
                    leading: Icon(
                      _isFavorito ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    title: const Text("Favoritos"),
                    trailing: Switch(
                      value: _isFavorito,
                      activeColor: Colors.red,
                      onChanged: (val) {
                        _toggleStatus('FAV', val);
                        setModalState(() {});
                      },
                    ),
                  ),

                  // Opción 2: Pendientes
                  ListTile(
                    leading: Icon(
                      _isPendiente
                          ? Icons.watch_later
                          : Icons.watch_later_outlined,
                      color: Colors.blue,
                    ),
                    title: const Text("Quiero ir (Pendientes)"),
                    trailing: Switch(
                      value: _isPendiente,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        _toggleStatus('PEND', val);
                        setModalState(() {});
                      },
                    ),
                  ),

                  // Opción 3: Visitados
                  ListTile(
                    leading: Icon(
                      _isVisitado
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    title: const Text("Ya visitado"),
                    trailing: Switch(
                      value: _isVisitado,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        _toggleStatus('VISIT', val);
                        setModalState(() {});
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = Theme.of(context).primaryColor;
    final lugar = widget.lugar;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. IMAGEN DE CABECERA ---
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Image.network(
                    lugar.urlImagenPrincipal ?? "https://via.placeholder.com/400x300",
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
                ),
                // Botón Atrás
                Positioned(
                  top: 40,
                  left: 16,
                  child: _buildCircleBtn(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                // Botón Favorito Rápido (Top Right)
                Positioned(
                  top: 40,
                  right: 16,
                  child: _buildCircleBtn(
                    icon: _isFavorito ? Icons.favorite : Icons.favorite_border,
                    colorIcon: _isFavorito ? Colors.red : Colors.black,
                    onTap: () => _toggleStatus('FAV', !_isFavorito),
                  ),
                ),
              ],
            ),

            // --- 2. CONTENIDO ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categorías
                  if (lugar.categorias.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: lugar.categorias.map((categoria) {
                        return Chip(
                          label: Text(categoria.nombre),
                          backgroundColor: Colors.grey[200],
                          labelStyle: const TextStyle(color: Colors.black54),
                        );
                      }).toList(),
                    )
                  else
                    Chip(
                      label: const Text("General"),
                      backgroundColor: Colors.grey[200],
                      labelStyle: const TextStyle(color: Colors.black54),
                    ),
                  const SizedBox(height: 16),

                  // Título
                  Text(
                    lugar.nombre,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Calificación y Estado Visitado
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "(0 reseñas)", // TODO: Traer reseñas reales
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const Spacer(),
                      // Badge visual si ya fue visitado
                      if (_isVisitado)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check, size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                "Visitado",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Descripción
                  const Text(
                    "Descripción",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lugar.descripcion,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Información Adicional
                  if (lugar.direccionCompleta != null) ...[
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      "Dirección",
                      lugar.direccionCompleta!,
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  if (lugar.horarios != null) ...[
                    _buildInfoRow(
                      Icons.access_time,
                      "Horarios",
                      lugar.horarios!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (lugar.contacto != null) ...[
                     _buildInfoRow(
                      Icons.phone_outlined,
                      "Contacto",
                      lugar.contacto!,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- 3. BOTONES DE ACCIÓN ---
                  Row(
                    children: [
                      // Botón GUARDAR (Abre menú)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _mostrarOpcionesGuardado(context),
                          icon: Icon(
                            _isPendiente
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: _isPendiente ? primaryPurple : Colors.black,
                            size: 20,
                          ),
                          label: Text(
                            "Guardar",
                            style: TextStyle(
                              color: _isPendiente
                                  ? primaryPurple
                                  : Colors.black,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: _isPendiente
                                  ? primaryPurple
                                  : Colors.grey[300]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Botón VER EN MAPA
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mapa(lugar: lugar),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.map_outlined,
                            size: 20,
                            color: Colors.black,
                          ),
                          label: const Text(
                            "Ver Mapa",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Botón IR (Navegación Interna)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Mapa(
                                  lugar: lugar,
                                  startNavigation: true,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.navigation,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: const Text(
                            "Ir",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para botones redondos flotantes
  Widget _buildCircleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color colorIcon = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, color: colorIcon, size: 24),
      ),
    );
  }

  // Widget auxiliar para filas de información
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[700], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
