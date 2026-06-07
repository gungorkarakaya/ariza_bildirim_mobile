import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/ariza_bildirim_model.dart';
import 'token_storage_service.dart';

class ArizaBildirimService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<List<ArizaBildirimModel>> getActiveArizaBildirimleri() async {
    final accessToken = await _tokenStorageService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.activeArizaBildirimListUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Aktif arıza listesi alınamadı. Status: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body);

    final data = json['data'];

    if (data == null) {
      return [];
    }

    if (data is! List) {
      throw Exception('Aktif arıza liste formatı beklenen yapıda değil.');
    }

    return data
        .map(
          (item) => ArizaBildirimModel.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }
}

class UnauthorizedException implements Exception {
  @override
  String toString() {
    return 'Oturum süresi doldu. Lütfen tekrar giriş yapın.';
  }
}