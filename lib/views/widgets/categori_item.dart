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

    // Scale dengan clamp agar tidak overflow di layar kecil/besar
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(s(15)),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: s(90),
          margin: EdgeInsets.only(right: s(12)),
          padding: EdgeInsets.symmetric(vertical: s(10)),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFA726)
                : const Color(0xFFFFB84C).withOpacity(0.85),
            borderRadius: BorderRadius.circular(s(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: s(6),
                offset: Offset(0, s(3)),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ================= ICON =================
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Image.asset(
                  iconPath,
                  width: s(26),
                  height: s(26),
                  // Fallback jika gambar gagal load
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.category_outlined,
                    size: s(26),
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),

              SizedBox(height: s(6)),

              // ================= TITLE =================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(4)),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: s(11),
                    color: isSelected ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
