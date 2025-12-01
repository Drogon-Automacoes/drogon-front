import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Adiciona Interceptors (O "Middleware" do Front-end)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Antes de enviar, verifica se temos token salvo
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');

          if (token != null) {
            // 2. Se tiver, injeta no Header automaticamente
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          print('--> ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log de sucesso
          print('<-- ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Log de erro
          print('<-- ERRO: ${e.response?.statusCode} ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
}