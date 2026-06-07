class ArizaBildirimModel {
  final int id;
  final int? konsolNo;
  final String departmanAdi;
  final String aciklama;
  final int durum;
  final String durumAdi;
  final String arizaCesidiAdi;
  final DateTime? created;

  ArizaBildirimModel({
    required this.id,
    required this.konsolNo,
    required this.departmanAdi,
    required this.aciklama,
    required this.durum,
    required this.durumAdi,
    required this.arizaCesidiAdi,
    required this.created,
  });

  factory ArizaBildirimModel.fromJson(Map<String, dynamic> json) {
    return ArizaBildirimModel(
      id: json['id'] ?? 0,
      konsolNo: json['konsolNo'],
      departmanAdi: json['departmanAdi'] ?? '',
      aciklama: json['aciklama'] ?? '',
      durum: json['durum'] ?? 0,
      durumAdi: json['durumAdi'] ?? '',
      arizaCesidiAdi: json['arizaCesidiAdi'] ?? '',
      created: json['created'] == null
          ? null
          : DateTime.tryParse(json['created'].toString()),
    );
  }
}