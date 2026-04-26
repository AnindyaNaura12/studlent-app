import 'package:flutter/material.dart';
import '../../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale dengan clamp agar tidak overflow di layar kecil/besar
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(s(18)),
        onTap: () {
          // TODO: navigasi ke halaman kategori
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(s(18)),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD8A8), Color(0xFFFFB74D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.25),
                blurRadius: s(12),
                offset: Offset(0, s(6)),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(s(12)),
            child: Row(
              children: [
                // ================= ICON =================
                Container(
                  padding: EdgeInsets.all(s(8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(s(10)),
                  ),
                  child: Image.asset(
                    category.iconPath,
                    width: s(26),
                    height: s(26),
                    // Fallback jika gambar gagal load
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.category_outlined,
                      size: s(26),
                      color: Colors.orange,
                    ),
                  ),
                ),

                SizedBox(width: s(10)),

                // ================= TITLE =================
                Expanded(
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontSize: s(13),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
