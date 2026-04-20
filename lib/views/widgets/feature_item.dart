import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final String iconPath;
  final String label;

  const FeatureItem({super.key, required this.iconPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(iconPath, height: 45, fit: BoxFit.contain),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
