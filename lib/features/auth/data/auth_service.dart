import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import 'user_model.dart';

class AuthService {
  final ApiClient client;
  final SharedPreferences prefs;

  AuthService(this.client, this.prefs);

  Future<void> login(String email, String password) async {
    try {
      final response = await client.dio.post(
        '/login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final token = response.data['access_token'];

      // Salva o token para as próximas requisições
      await prefs.setString('access_token', token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception("Email ou senha incorretos.");
      }
      throw Exception("Erro de conexão. Tente novamente.");
    }
  }

  Future<void> logout() async {
    await prefs.remove('access_token');
  }

  Future<UserModel> getUserMe() async {
    final response = await client.dio.get('/usuarios/me');
    return UserModel.fromJson(response.data);
  }
}
