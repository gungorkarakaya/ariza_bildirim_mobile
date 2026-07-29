import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';

class DeviceTokenService {
  Future<void> registerDeviceToken({
    required String accessToken,
    required String fcmToken,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.deviceTokenRegisterUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'token': fcmToken,
        'platform': 'Android',
        'deviceName': 'Android Emulator',
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 204) {
      throw Exception(
        'Device token kayıt başarısız. Status: ${response.statusCode}',
      );
    }
  }

  Future<void> unregisterDeviceToken({
    required String accessToken,
    required String fcmToken,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.deviceTokenUnregisterUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'token': fcmToken,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Device token pasifleştirme başarısız. Status: ${response.statusCode}',
      );
    }
  }
}