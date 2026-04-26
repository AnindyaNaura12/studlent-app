import 'package:flutter/material.dart';
import '/models/services_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM (biar konsisten sama page lain)
    double scale(double size) => size * (screenWidth / 375);

    return Container(
      width: scale(180), // 🔥 responsive (dari 190)
      margin: EdgeInsets.only(right: scale(14), bottom: scale(4)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: scale(10),
            offset: Offset(0, scale(3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= IMAGE =================
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(scale(16)),
            ),
            child: SizedBox(
              height: scale(150),
              width: double.infinity,
              child: Image.asset(
                service.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: scale(50),
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),

          // ================= INFO =================
          Padding(
            padding: EdgeInsets.fromLTRB(
              scale(12),
              scale(10),
              scale(12),
              scale(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // NAME + RATING
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: scale(13),
                          color: const Color(0xFFFFB74D),
                        ),
                      ),
                    ),
                    SizedBox(width: scale(4)),
                    Icon(Icons.star, color: Colors.orange, size: scale(12)),
                    SizedBox(width: scale(2)),
                    Text(
                      '${service.rating}',
                      style: TextStyle(
                        fontSize: scale(10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: scale(6)),

                // SKILLS
                Text(
                  service.skills,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: scale(11),
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),

                SizedBox(height: scale(4)),

                // UNIVERSITY
                Text(
                  service.university,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: scale(10),
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: scale(10)),

                // PRICE BUTTON
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: scale(8)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB74D),
                    borderRadius: BorderRadius.circular(scale(20)),
                  ),
                  child: Text(
                    service.price,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: scale(12),
                      color: Colors.black,
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