import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM (sama seperti page lain)
    double scale(double size) => size * (screenWidth / 375);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(scale(15)),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: scale(90), // 🔥 responsive width
          margin: EdgeInsets.only(right: scale(12)),
          padding: EdgeInsets.symmetric(vertical: scale(10)),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFA726)
                : const Color(0xFFFFB84C).withOpacity(0.85),
            borderRadius: BorderRadius.circular(scale(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: scale(6),
                offset: Offset(0, scale(3)),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Image.asset(
                  iconPath,
                  width: scale(26), // 🔥 responsive icon
                  height: scale(26),
                ),
              ),

              SizedBox(height: scale(6)),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: scale(11), // 🔥 responsive text
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}