class Usuario {
  final int id;
  final String username;
  final String email;
  final String nombreDisplay;
  final String? bio;
  final String? urlFotoPerfil;

  Usuario({
    required this.id,
    required this.username,
    required this.email,
    required this.nombreDisplay,
    this.bio,
    this.urlFotoPerfil,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      nombreDisplay: json['nombreDisplay'],
      bio: json['bio'],
      urlFotoPerfil: json['urlFotoPerfil'],
    );
  }
}
