import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class AuthService {
  static const String _connectionErrorMessage =
      'Sunucuya ulaşılamadı. Lütfen kurum ağına bağlı olduğunuzu kontrol edin.';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConstants.loginUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 400 || response.statusCode == 401) {
        throw Exception('Kullanıcı adı veya şifre hatalı.');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        final backendMessage = _getBackendErrorMessage(response.body);

        throw Exception(
          backendMessage ??
              'Giriş yapılamadı. Lütfen daha sonra tekrar deneyin.',
        );
      }

      final responseJson = jsonDecode(response.body);

      final accessToken =
          responseJson['data']?['accessToken'] ?? responseJson['accessToken'];

      if (accessToken == null || accessToken.toString().isEmpty) {
        throw Exception('Access token alınamadı.');
      }

      return accessToken.toString();
    } on SocketException {
      throw Exception(_connectionErrorMessage);
    } on TimeoutException {
      throw Exception(_connectionErrorMessage);
    } on http.ClientException {
      throw Exception(_connectionErrorMessage);
    } on FormatException {
      throw Exception('Sunucudan geçersiz bir yanıt alındı.');
    }
  }

  String? _getBackendErrorMessage(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return null;
    }

    try {
      final decodedBody = jsonDecode(responseBody);

      if (decodedBody is Map<String, dynamic>) {
        final message =
            decodedBody['message'] ??
            decodedBody['Message'] ??
            decodedBody['error'] ??
            decodedBody['title'];

        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }

        final data = decodedBody['data'];

        if (data is Map<String, dynamic>) {
          final dataMessage = data['message'] ?? data['Message'];

          if (dataMessage != null && dataMessage.toString().trim().isNotEmpty) {
            return dataMessage.toString();
          }
        }
      }
    } on FormatException {
      final plainText = responseBody.trim();

      if (plainText.isNotEmpty && plainText.length <= 300) {
        return plainText;
      }
    }

    return null;
  }
}
