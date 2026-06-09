class Usuario {
  final int id;
  final String nome;
  final String email;
  final String perfil;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      perfil: json['perfil'] as String,
    );
  }
}
