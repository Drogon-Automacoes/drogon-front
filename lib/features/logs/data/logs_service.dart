import '../../../core/network/api_client.dart';
import 'log_model.dart';

class LogsService {
  final ApiClient client;

  LogsService(this.client);

  Future<List<LogModel>> getLogs() async {
    try {
      final response = await client.dio.get('/logs/');
      final list = response.data as List;
      return list.map((e) => LogModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar logs. Verifique se é Admin.");
    }
  }
}