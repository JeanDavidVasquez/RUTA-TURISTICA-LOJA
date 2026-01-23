/// Modelos para ubicación jerárquica (Provincia, Canton, Parroquia)
library;

class Provincia {
  final int id;
  final String nombre;

  Provincia({required this.id, required this.nombre});

  factory Provincia.fromJson(Map<String, dynamic> json) {
    return Provincia(id: json['id'], nombre: json['nombre']);
  }
}

class Canton {
  final int id;
  final String nombre;
  final int provinciaId;
  final String? provinciaNombre;

  Canton({
    required this.id,
    required this.nombre,
    required this.provinciaId,
    this.provinciaNombre,
  });

  factory Canton.fromJson(Map<String, dynamic> json) {
    return Canton(
      id: json['id'],
      nombre: json['nombre'],
      provinciaId: json['provincia'],
      provinciaNombre: json['provincia_nombre'],
    );
  }
}

class Parroquia {
  final int id;
  final String nombre;
  final int cantonId;
  final String? cantonNombre;
  final String? provinciaNombre;

  Parroquia({
    required this.id,
    required this.nombre,
    required this.cantonId,
    this.cantonNombre,
    this.provinciaNombre,
  });

  factory Parroquia.fromJson(Map<String, dynamic> json) {
    return Parroquia(
      id: json['id'],
      nombre: json['nombre'],
      cantonId: json['canton'],
      cantonNombre: json['canton_nombre'],
      provinciaNombre: json['provincia_nombre'],
    );
  }
}
