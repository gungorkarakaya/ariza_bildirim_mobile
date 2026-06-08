import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(
          Icons.construction,
          size: 58,
          color: Colors.red,
        ),
        SizedBox(height: 10),
        Text(
          'ARIZA BİLDİRİM MOBİL',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'ADMİN PANELİ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}