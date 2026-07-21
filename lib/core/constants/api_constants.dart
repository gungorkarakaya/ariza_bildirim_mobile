class ApiConstants {
  static const String baseUrl = 'http://192.168.2.10';

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

}