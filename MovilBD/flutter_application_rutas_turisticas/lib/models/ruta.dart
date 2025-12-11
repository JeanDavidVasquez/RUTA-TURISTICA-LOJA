import 'categoria.dart';

class Ruta {
  final int id;
  final String nombre;
  final String descripcion;
  final String visibilidadRuta;
  final String? urlImagenPortada;
  final int duracionEstimadaSeg;
  final String distanciaEstimadaKm;
  final int usuario;
  final String usuarioUsername;
  final List<Categoria> categorias;
  final int numGuardados;

  Ruta({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.visibilidadRuta,
    this.urlImagenPortada,
    required this.duracionEstimadaSeg,
    required this.distanciaEstimadaKm,
    required this.usuario,
    required this.usuarioUsername,
    this.categorias = const [],
    this.numGuardados = 0,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      visibilidadRuta: json['visibilidadRuta'],
      urlImagenPortada: json['urlImagenPortada'],
      duracionEstimadaSeg: json['duracionEstimadaSeg'],
      // La API devuelve string o number para decimales, aseguramos string para parseo o double
      distanciaEstimadaKm: json['distanciaEstimadaKm'].toString(),
      usuario: json['usuario'],
      usuarioUsername: json['usuario_username'],
      categorias: (json['categorias'] as List<dynamic>?)
              ?.map((item) => Categoria.fromJson(item))
              .toList() ??
          [],
      numGuardados: json['num_guardados'] ?? 0,
    );
  }
}
