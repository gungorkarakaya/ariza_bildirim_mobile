import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class AuthService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.loginUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 400 || response.statusCode == 401) {
      throw Exception('Kullanıcı adı veya şifre hatalı.');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Giriş yapılamadı. Lütfen daha sonra tekrar deneyin.');
    }

    final json = jsonDecode(response.body);

    final accessToken = json['data']?['accessToken'] ?? json['accessToken'];

    if (accessToken == null || accessToken.toString().isEmpty) {
      throw Exception('Access token alınamadı.');
    }

    return accessToken.toString();
  }
}