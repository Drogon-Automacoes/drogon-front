import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'portao_model.dart';

class PortoesService {
  final ApiClient client;

  PortoesService(this.client);

  // GET /portoes/
  Future<List<PortaoModel>> getPortoes() async {
    try {
      final response = await client.dio.get('/portoes/');
      final list = response.data as List;
      return list.map((e) => PortaoModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar portões");
    }
  }

  // POST /portoes/{id}/acionar
  Future<void> acionarPortao(String id, String acao) async {
    await client.dio.post(
      '/portoes/$id/acionar',
      data: {'acao': acao},
    );
  }

  Future<void> cadastrarPortao(String nome, String topico) async {
    try {
      await client.dio.post(
        '/portoes/',
        data: {
          "nome": nome,
          "topico_mqtt": topico,
          "em_manutencao": false
        },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception("Apenas síndicos podem cadastrar portões.");
      }
      throw Exception("Erro ao cadastrar portão.");
    }
  }
}