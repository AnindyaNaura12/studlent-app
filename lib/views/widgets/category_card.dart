import 'package:flutter/material.dart';
import '../../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(s(14)),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(s(14)),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFFFD8A8), Color(0xFFFFF3E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF9800)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.orange.withOpacity(0.4)
                      : Colors.orange.withOpacity(0.15),
                  blurRadius: s(12),
                  offset: Offset(0, s(6)),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ================= ICON =================
                Container(
                  padding: EdgeInsets.all(s(8)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(s(10)),
                  ),
                  child: Image.asset(
                    category.iconPath,
                    width: s(26),
                    height: s(26),
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.category_outlined,
                      size: s(26),
                      color: isSelected ? Colors.white : Colors.orange,
                    ),
                  ),
                ),

                SizedBox(height: s(6)),

                // ================= TITLE =================
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: s(4)),
                  child: Text(
                    category.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: s(10),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}