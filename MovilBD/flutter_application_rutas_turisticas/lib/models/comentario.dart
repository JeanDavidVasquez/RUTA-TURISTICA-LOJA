class Comentario {
  final int id;
  final int usuario;
  final String usuarioUsername;
  final String? usuarioFoto;
  final int publicacion;
  final String texto;
  final DateTime fechaCreacion;

  Comentario({
    required this.id,
    required this.usuario,
    required this.usuarioUsername,
    this.usuarioFoto,
    required this.publicacion,
    required this.texto,
    required this.fechaCreacion,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'],
      usuario: json['usuario'],
      usuarioUsername: json['usuario_username'] ?? 'Anónimo',
      usuarioFoto: json['usuario_foto'],
      publicacion: json['publicacion'],
      texto: json['texto'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }
}
