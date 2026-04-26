import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final String iconPath;
  final String label;

  const FeatureItem({
    super.key,
    required this.iconPath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM
    double scale(double size) => size * (screenWidth / 375);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ICON
          Image.asset(
            iconPath,
            height: scale(40), // 🔥 responsive icon
            fit: BoxFit.contain,
          ),

          SizedBox(height: scale(8)),

          // LABEL
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: scale(11), // 🔥 responsive font
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.black87,
            ),
            maxLines: 2, // 🔥 penting biar aman
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}