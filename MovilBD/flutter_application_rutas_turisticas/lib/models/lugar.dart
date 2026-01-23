import 'categoria.dart';

class Lugar {
  final int id;
  final String nombre;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String? direccionCompleta;
  final String? provincia;
  final String? canton;
  final String? parroquia;
  final String? horarios;
  final String? contacto;
  final String? urlImagenPrincipal;
  final List<Categoria> categorias;
  final double ratingPromedio;
  final int numResenas;

  Lugar({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    this.direccionCompleta,
    this.provincia,
    this.canton,
    this.parroquia,
    this.horarios,
    this.contacto,
    this.urlImagenPrincipal,
    this.categorias = const [],
    this.ratingPromedio = 0.0,
    this.numResenas = 0,
  });

  factory Lugar.fromJson(Map<String, dynamic> json) {
    // Parseo seguro de rating_promedio - puede venir como null, int o double
    double parseRating(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    
    return Lugar(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      latitud: double.parse(json['latitud'].toString()),
      longitud: double.parse(json['longitud'].toString()),
      direccionCompleta: json['direccionCompleta'],
      provincia: json['provincia'],
      canton: json['canton'],
      parroquia: json['parroquia'],
      horarios: json['horarios'],
      contacto: json['contacto'],
      urlImagenPrincipal: json['urlImagenPrincipal'],
      categorias: (json['categorias'] as List<dynamic>?)
              ?.map((item) => Categoria.fromJson(item))
              .toList() ??
          [],
      ratingPromedio: parseRating(json['rating_promedio']),
      numResenas: json['num_resenas'] ?? 0,
    );
  }
}
