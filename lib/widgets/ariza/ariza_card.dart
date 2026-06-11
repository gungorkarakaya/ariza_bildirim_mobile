import 'package:flutter/material.dart';

import '../../models/ariza_bildirim_model.dart';
import 'ariza_info_row.dart';

class ArizaCard extends StatelessWidget {
  final ArizaBildirimModel ariza;
  final VoidCallback? onResolvePressed;

  const ArizaCard({
    super.key,
    required this.ariza,
    this.onResolvePressed,
  });

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatKonsolNo(int? konsolNo) {
    if (konsolNo == null) {
      return '-';
    }

    return 'K${konsolNo.toString().padLeft(2, '0')}';
  }

  String _formatAciklama(String aciklama) {
    if (aciklama.trim().isEmpty) {
      return '-';
    }

    return aciklama.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ariza.arizaCesidiAdi.isEmpty
                  ? 'Arıza Bildirimi'
                  : ariza.arizaCesidiAdi,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ArizaInfoRow(
              icon: Icons.desktop_windows_outlined,
              label: 'Konsol',
              value: _formatKonsolNo(ariza.konsolNo),
            ),
            ArizaInfoRow(
              icon: Icons.apartment_outlined,
              label: 'Departman',
              value: ariza.departmanAdi,
            ),
            ArizaInfoRow(
              icon: Icons.description_outlined,
              label: 'Açıklama',
              value: _formatAciklama(ariza.aciklama),
            ),
            ArizaInfoRow(
              icon: Icons.access_time,
              label: 'Tarih',
              value: _formatDate(ariza.created),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResolvePressed,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Çözüldü Yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}