import 'package:flutter/material.dart';

class ArizaErrorView extends StatelessWidget {
  final String message;

  const ArizaErrorView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}