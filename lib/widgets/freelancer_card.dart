import 'package:flutter/material.dart';

class FreelancerCard extends StatelessWidget {
  final String name;
  final double rating;
  final int reviewCount;
  final String experience;
  final String skills;
  final String university;
  final String price;
  final String imagePath;

  const FreelancerCard({
    super.key,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.skills,
    required this.university,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 14, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Foto ──
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, size: 52, color: Colors.grey),
                ),
              ),
            ),
          ),

          // ── Info bawah ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama (kuning) + Rating (tebal)
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFFFB74D), // kuning sesuai mockup
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, color: Colors.orange, size: 13),
                    const SizedBox(width: 2),
                    Text(
                      '$rating ($reviewCount)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // rating dicetak tebal
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Experience + Skills
                Text(
                  '$experience\nExpert in $skills.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // University
                Text(
                  university,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Harga — pill orange, font hitam
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB74D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    price,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black, // harga warna hitam
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}