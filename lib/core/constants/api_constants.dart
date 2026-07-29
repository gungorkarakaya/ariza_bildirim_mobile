class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5286';

  static const String loginUrl = '$baseUrl/api/auth/createtoken';

  static const String deviceTokenRegisterUrl =
      '$baseUrl/api/mobile/device-token/register';

  static const String activeArizaBildirimListUrl =
      '$baseUrl/api/mobile/ariza-bildirim/active';

  static const String markSeenArizaBildirimUrl =
      '$baseUrl/api/mobile/ariza-bildirim/mark-seen';

  static String resolveArizaBildirimUrl(int id) =>
      '$baseUrl/api/mobile/ariza-bildirim/$id/resolve';

  static const String arizaHubUrl = '$baseUrl/arizaHub';

  static const String deviceTokenUnregisterUrl =
      '$baseUrl/api/mobile/device-token/unregister';

}