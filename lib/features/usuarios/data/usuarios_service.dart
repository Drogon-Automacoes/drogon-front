import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/user_model.dart';

class UsuariosService {
  final ApiClient client;
  UsuariosService(this.client);

  // Cadastrar Morador
  Future<void> cadastrarMorador(String nome, String email, String senha) async {
    try {
      await client.dio.post('/usuarios/', data: {
        "nome": nome,
        "email": email,
        "senha": senha,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Erro ao cadastrar");
    }
  }
  
  Future<List<UserModel>> getMoradores() async {
    try {
      final response = await client.dio.get('/usuarios/');
      return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erro ao listar moradores.");
    }
  }

  Future<void> toggleBloqueio(String id) async {
    await client.dio.patch('/usuarios/$id/toggle-ativo');
  }
}