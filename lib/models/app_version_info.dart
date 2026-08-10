class AppVersionInfo {
  final String latestVersion;
  final String minimumVersion;
  final bool isMandatory;
  final String downloadUrl;
  final String releaseNotes;

  const AppVersionInfo({
    required this.latestVersion,
    required this.minimumVersion,
    required this.isMandatory,
    required this.downloadUrl,
    required this.releaseNotes,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      latestVersion: json['latestVersion']?.toString() ?? '',
      minimumVersion: json['minimumVersion']?.toString() ?? '',
      isMandatory: json['isMandatory'] == true,
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      releaseNotes: json['releaseNotes']?.toString() ?? '',
    );
  }
}
