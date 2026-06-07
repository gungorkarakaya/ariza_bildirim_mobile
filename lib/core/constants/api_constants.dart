class ApiConstants {
  static const String baseUrl = 'https://10.0.2.2:7165';

  static const String loginUrl = '$baseUrl/api/auth/createtoken';

  static const String deviceTokenRegisterUrl = '$baseUrl/api/mobile/device-token/register';

  static const String activeArizaBildirimListUrl =
      '$baseUrl/api/mobile/ariza-bildirim/active';
}