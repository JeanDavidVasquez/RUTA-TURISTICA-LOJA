import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:http/http.dart' as http;
import '../models/ruta.dart';
import '../models/lugar.dart';
import '../models/ruta_lugar.dart';
import '../models/usuario.dart';
import '../models/categoria.dart';

class ApiService {
  // Configuracion de URL Base
  // Para Web (Chrome): Usamos localhost
  // Para Android Emulador: Usamos 10.0.2.2
  // Para Dispositivo Físico: Usar IP local de tu PC (ej: 192.168.1.X) ('ipconfig' en terminal)

  String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    // emulador Android:
    return 'http://10.0.2.2:8000/api';

    // DISPOSITIVO FÍSICO:
    // return 'http://192.168.1.105:8000/api';
  }

  // Almacenamiento simple del ID de usuario en memoria (se pierde al reiniciar app)
  // En producción usar SharedPreferences o SecureStorage
  static int? currentUserId;

  Future<List<Ruta>> fetchRutas() async {
    final response = await http.get(Uri.parse('$baseUrl/rutas/'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Ruta> rutas = body
          .map((dynamic item) => Ruta.fromJson(item))
          .toList();
      return rutas;
    } else {
      throw Exception('Failed to load rutas: ${response.statusCode}');
    }
  }

  Future<List<Lugar>> fetchLugares() async {
    final response = await http.get(Uri.parse('$baseUrl/lugares/'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Lugar> lugares = body
          .map((dynamic item) => Lugar.fromJson(item))
          .toList();
      return lugares;
    } else {
      throw Exception('Failed to load lugares: ${response.statusCode}');
    }
  }

  Future<Lugar> getLugar(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/lugares/$id/'));

    if (response.statusCode == 200) {
      return Lugar.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load lugar: ${response.statusCode}');
    }
  }

  Future<List<Categoria>> fetchCategorias() async {
    final response = await http.get(Uri.parse('$baseUrl/categorias/'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Categoria> categorias = body
          .map((dynamic item) => Categoria.fromJson(item))
          .toList();
      return categorias;
    } else {
      throw Exception('Failed to load categorias: ${response.statusCode}');
    }
  }

  Future<List<RutaLugar>> fetchRutaLugares(int rutaId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/ruta-lugares/?ruta=$rutaId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<RutaLugar> rutaLugares = body
          .map((dynamic item) => RutaLugar.fromJson(item))
          .toList();
      return rutaLugares;
    } else {
      throw Exception('Failed to load ruta lugares: ${response.statusCode}');
    }
  }

  Future<Usuario> getUserProfile(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/usuarios/$userId/'));

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print("ApiService: Login called for $email");
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/usuarios/login/'),
            body: {'email': email, 'password': password},
          )
          .timeout(const Duration(seconds: 10));
      print("ApiService: Response received ${response.statusCode}");
      print("ApiService: Body ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          currentUserId = data['user']['id']; // Guardamos el ID
        }
        return data;
      } else {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw Exception('Error de conexión: ${response.statusCode}');
        }
      }
    } catch (e) {
      print("ApiService: Error $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/'),
      body: {
        'username': username,
        'email': email,
        'password': password,
        'nombreDisplay': username, // Por defecto
      },
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar: ${response.body}');
    }
  }
  // --- FAVORITOS / LISTAS ---

  Future<void> toggleFavorito(int lugarId, String tipo, bool isActive) async {
    if (currentUserId == null) return;

    // 1. Buscar si ya existe
    final existing = await _findFavorito(lugarId, tipo);

    if (isActive) {
      // Si queremos activarlo y no existe, lo creamos
      if (existing == null) {
        final response = await http.post(
          Uri.parse('$baseUrl/favoritos/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usuario': currentUserId,
            'lugar': lugarId,
            'tipo': tipo,
            'fecha': DateTime.now()
                .toIso8601String(), // Añadir fecha por si acaso
          }),
        );

        if (response.statusCode != 201) {
          throw Exception("Error creating favorite: ${response.body}");
        }
      }
    } else {
      // Si queremos desactivarlo y existe, lo borramos
      if (existing != null) {
        final response = await http.delete(
          Uri.parse('$baseUrl/favoritos/${existing['id']}/'),
        );
        if (response.statusCode != 204) {
          throw Exception("Error deleting favorite: ${response.body}");
        }
      }
    }
  }

  Future<Map<String, dynamic>?> _findFavorito(int lugarId, String tipo) async {
    if (currentUserId == null) return null;

    // Filtramos por usuario, lugar y tipo
    final response = await http.get(
      Uri.parse(
        '$baseUrl/favoritos/?usuario=$currentUserId&lugar=$lugarId&tipo=$tipo',
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data.first;
      }
    }
    return null;
  }

  // Obtiene el estado de las 3 listas para un lugar
  Future<Map<String, bool>> checkFavoritoStatus(int lugarId) async {
    if (currentUserId == null)
      return {'FAV': false, 'PEND': false, 'VISIT': false};

    final response = await http.get(
      Uri.parse('$baseUrl/favoritos/?usuario=$currentUserId&lugar=$lugarId'),
    );

    Map<String, bool> status = {'FAV': false, 'PEND': false, 'VISIT': false};

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      for (var item in data) {
        String tipo = item['tipo'];
        if (status.containsKey(tipo)) {
          status[tipo] = true;
        }
      }
    }
    return status;
  }

  Future<List<Lugar>> fetchUserFavoritos(String tipo) async {
    if (currentUserId == null) return [];

    try {
      // 1. Obtener la lista de IDs de favoritos
      final responseFavs = await http.get(
        Uri.parse('$baseUrl/favoritos/?usuario=$currentUserId&tipo=$tipo'),
      );

      if (responseFavs.statusCode != 200) {
        throw Exception('Error fetching favorites ids');
      }

      List<dynamic> favsData = jsonDecode(responseFavs.body);
      Set<int> lugarIds = favsData
          .map((f) {
            // Manejar si 'lugar' es un objeto o un ID
            if (f['lugar'] is int) {
              return f['lugar'] as int;
            } else if (f['lugar'] is Map) {
              return f['lugar']['id'] as int;
            }
            return -1; // Fallback
          })
          .where((id) => id != -1)
          .toSet();

      if (lugarIds.isEmpty) return [];

      // 2. Obtener todos los lugares (o filtrar si el backend lo permitiera)
      // Por ahora traemos todos y filtramos en memoria.
      // Optimización futura: Endpoint que reciba lista de IDs o filtro en backend.
      final allLugares = await fetchLugares();

      return allLugares.where((l) => lugarIds.contains(l.id)).toList();
    } catch (e) {
      print("Error fetching user favorites: $e");
      return [];
    }
  }

  // --- RUTAS GUARDADAS ---

  Future<void> toggleGuardarRuta(int rutaId, bool isActive) async {
    if (currentUserId == null) return;

    // 1. Buscar si ya existe
    final existing = await _findRutaGuardada(rutaId);

    if (isActive) {
      // Guardar
      if (existing == null) {
        await http.post(
          Uri.parse('$baseUrl/rutas-guardadas/'),
          body: {
            'usuario': currentUserId.toString(),
            'ruta': rutaId.toString(),
            'orden': '0', // Por defecto
          },
        );
      }
    } else {
      // Borrar
      if (existing != null) {
        await http.delete(
          Uri.parse('$baseUrl/rutas-guardadas/${existing['id']}/'),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> _findRutaGuardada(int rutaId) async {
    if (currentUserId == null) return null;

    final response = await http.get(
      Uri.parse(
        '$baseUrl/rutas-guardadas/?usuario=$currentUserId&ruta=$rutaId',
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data.first;
      }
    }
    return null;
  }

  Future<bool> checkRutaGuardadaStatus(int rutaId) async {
    if (currentUserId == null) return false;
    final existing = await _findRutaGuardada(rutaId);
    return existing != null;
  }

  Future<List<Ruta>> fetchRutasGuardadas() async {
    if (currentUserId == null) return [];

    try {
      // 1. Obtener IDs de rutas guardadas
      final response = await http.get(
        Uri.parse('$baseUrl/rutas-guardadas/?usuario=$currentUserId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Error fetching saved routes');
      }

      List<dynamic> data = jsonDecode(response.body);
      Set<int> rutaIds = data.map((item) => item['ruta'] as int).toSet();

      if (rutaIds.isEmpty) return [];

      // 2. Obtener todas las rutas y filtrar
      // (Igual que con favoritos, idealmente el backend filtraría)
      final allRutas = await fetchRutas();
      return allRutas.where((r) => rutaIds.contains(r.id)).toList();
    } catch (e) {
      print("Error fetching saved routes: $e");
      return [];
    }
  }

  // --- GESTIÓN DE RUTAS (CRUD) ---

  Future<Ruta> createRuta(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rutas/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return Ruta.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create ruta: ${response.body}');
    }
  }

  Future<Ruta> updateRuta(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/rutas/$id/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Ruta.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update ruta: ${response.body}');
    }
  }

  Future<void> deleteRuta(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/rutas/$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete ruta: ${response.body}');
    }
  }

  // --- GESTIÓN DE LUGARES EN RUTA ---

  Future<RutaLugar> addLugarToRuta(
    int rutaId,
    int lugarId,
    int orden, {
    int tiempoSugerido = 0,
    String? comentario,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ruta-lugares/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ruta': rutaId,
        'lugar': lugarId,
        'orden': orden,
        'tiempo_sugerido_minutos': tiempoSugerido,
        'comentario': comentario,
        'fechaGuardado': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      return RutaLugar.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add lugar to ruta: ${response.body}');
    }
  }

  Future<void> removeLugarFromRuta(int rutaLugarId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/ruta-lugares/$rutaLugarId/'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove lugar from ruta: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/$userId/stats/'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user stats');
    }
  }

  Future<Usuario> updateProfile(int userId, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/usuarios/$userId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  // --- RESEÑAS ---
  Future<List<dynamic>> getReviews(int targetId, String type) async {
    // type: 'lugar' or 'ruta'
    final response = await http.get(
      Uri.parse('$baseUrl/resenas/?$type=$targetId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> postReview(
    int targetId,
    String type,
    int rating,
    String text,
  ) async {
    if (currentUserId == null) throw Exception("User not logged in");

    final body = {
      'usuario': currentUserId,
      'calificacion': rating,
      'texto': text,
      type: targetId, // 'lugar': 123 or 'ruta': 456
    };

    final response = await http.post(
      Uri.parse('$baseUrl/resenas/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post review: ${response.body}');
    }
  }

  Future<void> updateReview(int reviewId, int rating, String text) async {
    final body = {'calificacion': rating, 'texto': text};

    final response = await http.patch(
      Uri.parse('$baseUrl/resenas/$reviewId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update review: ${response.body}');
    }
  }

  Future<void> deleteReview(int reviewId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/resenas/$reviewId/'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete review: ${response.body}');
    }
  }
}
