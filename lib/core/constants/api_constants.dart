import 'dart:io';

class ApiConstants {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'https://drogon-back.onrender.com/api/v1';
    } else {
      return 'https://drogon-back.onrender.com/api/v1';
    }
  }
}