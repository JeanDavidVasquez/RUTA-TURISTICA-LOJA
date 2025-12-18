class Publicacion {
  final int id;
  final int usuario;
  final String usuarioUsername;
  final String? usuarioFoto;
  final int lugar;
  final String lugarNombre;
  final String tipo;
  final String? archivoMedia;
  final String? descripcion;
  final String fecha;
  final bool esVisible;
  final bool esPropietario;

  Publicacion({
    required this.id,
    required this.usuario,
    required this.usuarioUsername,
    this.usuarioFoto,
    required this.lugar,
    required this.lugarNombre,
    required this.tipo,
    this.archivoMedia,
    this.descripcion,
    required this.fecha,
    required this.esVisible,
    this.esPropietario = false,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    return Publicacion(
      id: json['id'],
      usuario: json['usuario'],
      usuarioUsername: json['usuario_username'],
      usuarioFoto: json['usuario_foto'],
      lugar: json['lugar'],
      lugarNombre: json['lugar_nombre'],
      tipo: json['tipo'],
      archivoMedia: json['archivo_media'],
      descripcion: json['descripcion'],
      fecha: json['fecha'],
      esVisible: json['es_visible'] ?? true,
      esPropietario: json['es_propietario'] ?? false,
    );
  }
}
