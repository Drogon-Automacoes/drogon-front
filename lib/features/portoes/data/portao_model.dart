class PortaoModel {
  final String id;
  final String nome;
  final String topicoMqtt;
  final String statusAtual; // "aberto", "fechado"
  final bool emManutencao;

  PortaoModel({
    required this.id,
    required this.nome,
    required this.topicoMqtt,
    required this.statusAtual,
    required this.emManutencao,
  });

  factory PortaoModel.fromJson(Map<String, dynamic> json) {
    return PortaoModel(
      id: json['id'],
      nome: json['nome'],
      topicoMqtt: json['topico_mqtt'],
      statusAtual: json['status_atual'],
      emManutencao: json['em_manutencao'] ?? false,
    );
  }
  
  bool get isAberto => statusAtual == 'aberto';
}