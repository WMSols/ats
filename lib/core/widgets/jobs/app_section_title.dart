import 'package:flutter/material.dart';

class AppSectionTitle extends StatelessWidget {
  final String title;

  const AppSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

