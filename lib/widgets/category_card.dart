import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String iconPath;

  const CategoryCard({
    super.key,
    required this.title,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // penting untuk ripple
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // TODO: navigasi ke halaman kategori
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            // 🔥 Gradient halus (lebih hidup dari warna flat)
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFD8A8), // soft orange
                Color(0xFFFFB74D),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            // 🔥 Soft shadow (biar ada depth)
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ICON
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6), // 🔥 glass feel
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 30,
                    height: 30,
                  ),
                ),

                const SizedBox(width: 12),

                // TEXT
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
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