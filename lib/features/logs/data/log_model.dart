class LogModel {
  final String id;
  final String dataHora;
  final String acao;
  final bool sucesso;
  final String? observacao;
  final String usuarioId;
  final String usuarioNome; 

  LogModel({
    required this.id,
    required this.dataHora,
    required this.acao,
    required this.sucesso,
    this.observacao,
    required this.usuarioId,
    required this.usuarioNome,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'],
      dataHora: json['data_hora'],
      acao: json['acao'],
      sucesso: json['sucesso'],
      observacao: json['observacao'],
      usuarioId: json['usuario_id'],
      usuarioNome: json['usuario_nome'] ?? 'Desconhecido', 
    );
  }
}