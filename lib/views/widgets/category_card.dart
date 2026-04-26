import 'package:flutter/material.dart';
import '../../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM
    double scale(double size) => size * (screenWidth / 375);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(scale(18)),
        onTap: () {
          // TODO: navigasi ke halaman kategori
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scale(18)),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD8A8), Color(0xFFFFB74D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.25),
                blurRadius: scale(12),
                offset: Offset(0, scale(6)),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(scale(12)), // 🔥 responsive padding
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(scale(8)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(scale(10)),
                  ),
                  child: Image.asset(
                    category.iconPath,
                    width: scale(26), // 🔥 responsive icon
                    height: scale(26),
                  ),
                ),

                SizedBox(width: scale(10)),

                Expanded(
                  child: Text(
                    category.title,
                    style: TextStyle(
                      fontSize: scale(13), // 🔥 responsive text
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
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