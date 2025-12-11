import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../models/ruta.dart';
import '../models/ruta_lugar.dart';
import '../models/lugar.dart';
import '../services/api_service.dart';

class Mapa extends StatefulWidget {
  final Ruta? ruta;
  final List<RutaLugar>? rutaLugares;
  final Lugar? lugar;
  final bool startNavigation; // New parameter

  const Mapa({
    super.key, 
    this.ruta, 
    this.rutaLugares, 
    this.lugar,
    this.startNavigation = false,
  });

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Coordenadas por defecto (Loja)
  static const CameraPosition _kLoja = CameraPosition(
    target: LatLng(-3.99313, -79.20422),
    zoom: 14.4746,
  );

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {}; // To highlight user location
  List<RutaLugar> _rutaLugares = [];
  bool _mostrarModalRuta = false;
  bool _navegacionActiva = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<Position>? _userTrackingSubscription; // Always active

  @override
  void initState() {
    super.initState();
    if (widget.rutaLugares != null) {
      _rutaLugares = widget.rutaLugares!;
    }

    if (widget.ruta != null) {
      _mostrarModalRuta = true;
      _loadRouteData();
    } else if (widget.lugar != null) {
      _addMarkerForLugar(widget.lugar!);
    } else {
      // Exploration Mode: Show nearby places
      _loadNearbyPlaces();
    }
    _checkLocationPermission();

    // Auto-start navigation if requested
    if (widget.startNavigation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startInAppNavigation();
      });
    }
  }

  Future<void> _loadNearbyPlaces() async {
    // 1. Get User Location
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting location for nearby places: $e");
      return;
    }

    // 2. Fetch All Places
    final ApiService apiService = ApiService();
    try {
      final lugares = await apiService.fetchLugares();
      
      // 3. Filter Nearby (e.g., 5km radius)
      int count = 0;
      for (var lugar in lugares) {
        final dist = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          lugar.latitud, lugar.longitud,
        );

        if (dist <= 5000) { // 5km radius
          count++;
          _markers.add(
            Marker(
              markerId: MarkerId(lugar.id.toString()),
              position: LatLng(lugar.latitud, lugar.longitud),
              infoWindow: InfoWindow(
                title: lugar.nombre,
                snippet: "${(dist / 1000).toStringAsFixed(1)} km",
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {});
        if (count > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("📍 Se encontraron $count lugares cerca de ti.")),
          );
          // Move camera to user
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude), 14,
          ));
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("📍 No hay lugares turísticos registrados cerca de tu ubicación.")),
          );
        }
      }
    } catch (e) {
      print("Error loading nearby places: $e");
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _userTrackingSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Start tracking user for custom marker
    _startUserTracking();
  }

  void _startUserTracking() {
    _userTrackingSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          // 1. Update Halo Circle
          _circles.clear();
          _circles.add(
            Circle(
              circleId: const CircleId("user_halo"),
              center: LatLng(position.latitude, position.longitude),
              radius: 30, // 30 meters radius
              fillColor: Colors.blue.withOpacity(0.3),
              strokeColor: Colors.blue,
              strokeWidth: 1,
            ),
          );

          // 2. Update Custom User Marker (Large Dot)
          _markers.removeWhere((m) => m.markerId.value == "user_custom_pos");
          _markers.add(
            Marker(
              markerId: const MarkerId("user_custom_pos"),
              position: LatLng(position.latitude, position.longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              zIndex: 100, // On top of everything
              anchor: const Offset(0.5, 0.5), // Center the icon
            ),
          );
        });
      }
    });
  }

  void _addMarkerForLugar(Lugar lugar) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(lugar.id.toString()),
          position: LatLng(lugar.latitud, lugar.longitud),
          infoWindow: InfoWindow(title: lugar.nombre),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  Future<void> _loadRouteData() async {
    final ApiService apiService = ApiService();
    
    // 1. Fetch RutaLugares if missing
    if (_rutaLugares.isEmpty && widget.ruta != null) {
      try {
        _rutaLugares = await apiService.fetchRutaLugares(widget.ruta!.id);
      } catch (e) {
        print("Error fetching ruta lugares: $e");
      }
    }

    // 2. Fetch Lugares details and create Markers
    if (_rutaLugares.isNotEmpty) {
      List<LatLng> waypoints = [];
      try {
        final lugares = await apiService.fetchLugares();
        for (var i = 0; i < _rutaLugares.length; i++) {
          final rl = _rutaLugares[i];
          final lugar = lugares.firstWhere((l) => l.id == rl.lugar, orElse: () => lugares.first);
          final pos = LatLng(lugar.latitud, lugar.longitud);
          waypoints.add(pos);
          
          _markers.add(
            Marker(
              markerId: MarkerId(rl.lugar.toString()),
              position: pos,
              infoWindow: InfoWindow(title: "${i + 1}. ${rl.lugarNombre}"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            ),
          );
        }

        // 3. Draw Route
        if (waypoints.isNotEmpty) {
          _getRoutePolyline(waypoints);
          
          // Move camera to first point
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(waypoints.first, 14));
        }
      } catch (e) {
        print("Error loading route data: $e");
      }
      setState(() {});
    }
  }

  Future<void> _getRoutePolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return;

    // OSRM uses lon,lat
    String coordinates = waypoints.map((p) => "${p.longitude},${p.latitude}").join(';');
    final url = Uri.parse("http://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry']['coordinates'] as List;
          List<LatLng> polylinePoints = geometry.map((p) => LatLng(p[1].toDouble(), p[0].toDouble())).toList();

          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId("route"),
                points: polylinePoints,
                color: const Color(0xFF8667F2),
                width: 5,
              ),
            );
          });
        }
      }
    } catch (e) {
      print("Error fetching OSRM: $e");
    }
  }

  void _startInAppNavigation() async {
    print("DEBUG: Starting navigation...");
    setState(() {
      _navegacionActiva = true;
    });

    final GoogleMapController controller = await _controller.future;
    
    // 0. Immediate update with current position (if available)
    try {
      Position currentPos = await Geolocator.getCurrentPosition();
      print("DEBUG: Current position found: ${currentPos.latitude}, ${currentPos.longitude}");
      _updateNavigation(currentPos, controller);
    } catch (e) {
      print("DEBUG: Could not get current position immediately: $e");
    }

    // Start following user location
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      print("DEBUG: Position stream update: ${position.latitude}, ${position.longitude}");
      _updateNavigation(position, controller);
    });
  }

  void _updateNavigation(Position position, GoogleMapController controller) {
    LatLng? targetPos;
    
    // 1. Determine Target
    if (widget.lugar != null) {
      targetPos = LatLng(widget.lugar!.latitud, widget.lugar!.longitud);
    } else if (_rutaLugares.isNotEmpty) {
      // Find target marker for route (first place)
      final targetId = _rutaLugares.first.lugar.toString();
      final firstPlace = _markers.firstWhere(
        (m) => m.markerId.value == targetId,
        orElse: () => _markers.isNotEmpty ? _markers.first : const Marker(markerId: MarkerId("dummy")),
      );
      if (firstPlace.markerId.value != "dummy") {
        targetPos = firstPlace.position;
      }
    }

    // 2. Fetch Route if target exists
    if (targetPos != null) {
       // Only fetch if we haven't fetched recently or if significant movement? 
       // For now, we rely on _getRouteFromUserToStart handling updates efficiently or just overwriting.
       // Actually, we should probably throttle this, but let's keep it simple for now.
       
       _getRouteFromUserToStart(
          LatLng(position.latitude, position.longitude),
          targetPos,
        );

        // Check distance warning
        final dist = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          targetPos.latitude, targetPos.longitude,
        );
        
        if (dist > 50000) { 
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⚠️ Estás muy lejos del destino (¿Usando emulador?)."),
              duration: Duration(seconds: 2),
            ),
          );
        }
    }

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18.0,
          bearing: position.heading,
          tilt: 45.0,
        ),
      ),
    );
  }

  Future<void> _getRouteFromUserToStart(LatLng userPos, LatLng startPos) async {
    print("DEBUG: Getting route from $userPos to $startPos");
    
    // Fallback logic first (draw straight line immediately to ensure SOMETHING shows)
    if (mounted) {
      setState(() {
        _polylines.removeWhere((p) => p.polylineId.value == "user_route");
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("user_route"),
            points: [userPos, startPos],
            color: Colors.blue,
            width: 5,
            patterns: [PatternItem.dash(10), PatternItem.gap(10)],
          ),
        );
      });
    }

    // Then try to fetch real route
    String coordinates = "${userPos.longitude},${userPos.latitude};${startPos.longitude},${startPos.latitude}";
    final url = Uri.parse("http://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry']['coordinates'] as List;
          List<LatLng> polylinePoints = geometry.map((p) => LatLng(p[1].toDouble(), p[0].toDouble())).toList();

          print("DEBUG: OSRM route found with ${polylinePoints.length} points");
          if (mounted) {
            setState(() {
              _polylines.removeWhere((p) => p.polylineId.value == "user_route");
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId("user_route"),
                  points: polylinePoints,
                  color: Colors.blue,
                  width: 5,
                  patterns: [PatternItem.dash(10), PatternItem.gap(10)],
                ),
              );
            });
          }
        }
      } else {
        print("DEBUG: OSRM failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("DEBUG: Error fetching user route: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure tracking is active (fix for Hot Reload)
    if (_userTrackingSubscription == null) {
      _checkLocationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: (!_navegacionActiva && (widget.ruta != null || widget.lugar != null))
            ? Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: widget.lugar != null 
                ? CameraPosition(target: LatLng(widget.lugar!.latitud, widget.lugar!.longitud), zoom: 15)
                : _kLoja,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            polylines: _polylines,
            circles: _circles, // Add circles here
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // Modal de Ruta (Panel Inferior)
          if (_mostrarModalRuta && widget.ruta != null)
            Positioned(
              bottom: _navegacionActiva ? 90 : 20, // Subir si hay botón de detener
              left: 10,
              right: 10,
              child: _buildRutaPanel(widget.ruta!),
            ),
            
          // Botón Detener Navegación
          if (_navegacionActiva)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  _positionStreamSubscription?.cancel();
                  setState(() => _navegacionActiva = false);
                  _controller.future.then((c) => c.animateCamera(CameraUpdate.zoomTo(15)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Detener Navegación"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRutaPanel(Ruta ruta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Título y Cerrar
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${ruta.distanciaEstimadaKm} km • ${ruta.duracionEstimadaSeg ~/ 60} min",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (!_navegacionActiva)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => setState(() => _mostrarModalRuta = false),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Lista de Lugares (Panel Horizontal)
          if (_rutaLugares.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _rutaLugares.length,
                itemBuilder: (context, index) {
                  final rl = _rutaLugares[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: const Color(0xFF8667F2),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rl.lugarNombre,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
          const SizedBox(height: 16),
          
          // Botón Navegar (Solo si no estamos navegando)
          if (!_navegacionActiva)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startInAppNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8667F2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.navigation, size: 20),
                label: const Text(
                  "Comenzar navegación",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
