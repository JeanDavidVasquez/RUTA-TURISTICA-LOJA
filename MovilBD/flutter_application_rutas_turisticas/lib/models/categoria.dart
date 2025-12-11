class Categoria {
  final int id;
  final String nombre;
  final String? urlIcono;
  final String? urlImagen;

  Categoria({
    required this.id,
    required this.nombre,
    this.urlIcono,
    this.urlImagen,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
      urlIcono: json['urlIcono'],
      urlImagen: json['urlImagen'],
    );
  }
}
