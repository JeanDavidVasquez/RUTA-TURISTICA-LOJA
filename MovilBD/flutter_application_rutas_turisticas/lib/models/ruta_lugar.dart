class RutaLugar {
  final int id;
  final int orden;
  final int ruta;
  final String rutaNombre;
  final int lugar;
  final String lugarNombre;

  final int tiempoSugeridoMinutos;
  final String? comentario;

  RutaLugar({
    required this.id,
    required this.orden,
    required this.ruta,
    required this.rutaNombre,
    required this.lugar,
    required this.lugarNombre,
    this.tiempoSugeridoMinutos = 0,
    this.comentario,
  });

  factory RutaLugar.fromJson(Map<String, dynamic> json) {
    return RutaLugar(
      id: json['id'],
      orden: json['orden'],
      ruta: json['ruta'],
      rutaNombre: json['ruta_nombre'],
      lugar: json['lugar'],
      lugarNombre: json['lugar_nombre'],
      tiempoSugeridoMinutos: json['tiempo_sugerido_minutos'] ?? 0,
      comentario: json['comentario'],
    );
  }
}
