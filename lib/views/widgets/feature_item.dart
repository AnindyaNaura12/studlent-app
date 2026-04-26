import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final String iconPath;
  final String label;

  const FeatureItem({super.key, required this.iconPath, required this.label});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale dengan clamp agar tidak overflow di layar kecil/besar
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ================= ICON =================
          Image.asset(
            iconPath,
            height: s(40),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.star_outline, size: s(40), color: Colors.orange),
          ),

          SizedBox(height: s(8)),

          // ================= LABEL =================
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: s(11),
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
