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

  Future<void> markSeen(List<int> ids) async {
    if (ids.isEmpty) {
      return;
    }

    final accessToken = await _tokenStorageService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.markSeenArizaBildirimUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'ids': ids,
      }),
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Görüldü bilgisi gönderilemedi. Status: ${response.statusCode}',
      );
    }
  }

  Future<void> resolveAriza(int id) async {
    final accessToken = await _tokenStorageService.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Oturum bilgisi bulunamadı. Lütfen tekrar giriş yapın.');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.resolveArizaBildirimUrl(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Arıza çözüldü olarak işaretlenemedi. Status: ${response.statusCode}',
      );
    }
  }




}

class UnauthorizedException implements Exception {
  @override
  String toString() {
    return 'Oturum süresi doldu. Lütfen tekrar giriş yapın.';
  }
}