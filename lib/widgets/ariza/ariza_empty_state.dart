import 'package:flutter/material.dart';

class ArizaEmptyState extends StatelessWidget {
  const ArizaEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Şu anda aktif arıza bulunmuyor.'),
      ),
    );
  }
}