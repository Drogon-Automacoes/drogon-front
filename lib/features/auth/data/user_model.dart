class UserModel {
  final String id;
  final String email;
  final String nome;
  final String tipo;
  final bool ativo;
  final String? nomeCondominio;

  UserModel({
    required this.id, 
    required this.email, 
    required this.nome, 
    required this.tipo,
    required this.ativo,
    this.nomeCondominio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nome: json['nome'],
      tipo: json['tipo'],
      ativo: json['ativo'] ?? true,
      nomeCondominio: json['nome_condominio'],
    );
  }
  
  bool get isSuperAdmin => tipo == 'super_admin';
}