import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/api_constants.dart';
import '../models/app_version_info.dart';

class AppUpdateService {
  Future<AppVersionInfo> getAppVersionInfo() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.appVersionUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Güncelleme bilgisi alınamadı.');
      }

      final decodedBody = jsonDecode(response.body);

      if (decodedBody is! Map<String, dynamic>) {
        throw Exception('Sunucudan geçersiz güncelleme bilgisi alındı.');
      }

      return AppVersionInfo.fromJson(decodedBody);
    } on SocketException {
      throw Exception('Güncelleme sunucusuna ulaşılamadı.');
    } on TimeoutException {
      throw Exception('Güncelleme sunucusuna ulaşılamadı.');
    } on http.ClientException {
      throw Exception('Güncelleme sunucusuna ulaşılamadı.');
    } on FormatException {
      throw Exception('Sunucudan geçersiz güncelleme bilgisi alındı.');
    }
  }

  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  bool isNewerVersion({
    required String currentVersion,
    required String latestVersion,
  }) {
    final currentParts = currentVersion.split('.').map(int.parse).toList();

    final latestParts = latestVersion.split('.').map(int.parse).toList();

    final maxLength = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (var i = 0; i < maxLength; i++) {
      final current = i < currentParts.length ? currentParts[i] : 0;

      final latest = i < latestParts.length ? latestParts[i] : 0;

      if (latest > current) {
        return true;
      }

      if (latest < current) {
        return false;
      }
    }

    return false;
  }

  Future<bool> isUpdateAvailable() async {
    final versionInfo = await getAppVersionInfo();
    final currentVersion = await getCurrentVersion();

    return isNewerVersion(
      currentVersion: currentVersion,
      latestVersion: versionInfo.latestVersion,
    );
  }

  Future<void> downloadAndInstallApk({
    required String downloadUrl,
    required String version,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(downloadUrl))
          .timeout(const Duration(minutes: 2));

      if (response.statusCode != 200) {
        throw Exception('Güncelleme dosyası indirilemedi.');
      }

      final directory = await getTemporaryDirectory();

      final apkFile = File('${directory.path}/ArizaBildirim-v$version.apk');

      await apkFile.writeAsBytes(response.bodyBytes, flush: true);

      final result = await OpenFilex.open(
        apkFile.path,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        throw Exception('Kurulum ekranı açılamadı.');
      }
    } on SocketException {
      throw Exception('Güncelleme dosyasına ulaşılamadı.');
    } on TimeoutException {
      throw Exception('Güncelleme indirme işlemi zaman aşımına uğradı.');
    } on http.ClientException {
      throw Exception('Güncelleme dosyasına ulaşılamadı.');
    }
  }
}
