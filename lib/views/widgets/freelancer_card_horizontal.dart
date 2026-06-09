import 'package:flutter/material.dart';
import '/models/services_model.dart';

class FreelancerCardHorizontal extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const FreelancerCardHorizontal({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM
    double scale(double size) => size * (screenWidth / 375);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: scale(14)),
        padding: EdgeInsets.all(scale(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(scale(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: scale(10),
              offset: Offset(0, scale(5)),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE =================
            ClipRRect(
              borderRadius: BorderRadius.circular(scale(14)),
              child: SizedBox(
                width: scale(90),
                height: scale(90),
                child: _buildImage(service.imagePath),
              ),
            ),

            SizedBox(width: scale(12)),

            // ================= CONTENT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== TITLE SERVICE (baru) =====
                  Text(
                    service.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: scale(13),
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ===== CATEGORY =====
                  Text(
                    service.category.isNotEmpty ? service.category : "General",
                    style: TextStyle(
                      fontSize: scale(10),
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: scale(2)),

                  // ===== NAMA FREELANCER =====
                  Text(
                    service.name,
                    style: TextStyle(
                      color: const Color(0xFFFFB84C),
                      fontWeight: FontWeight.bold,
                      fontSize: scale(12),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ===== SHORT DESCRIPTION (baru, ganti skills) =====
                  Text(
                    service.basicPackage.shortDescription,
                    style: TextStyle(fontSize: scale(10), color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: scale(4)),

                  // ===== UNIVERSITY =====
                  Text(
                    service.university,
                    style: TextStyle(fontSize: scale(10)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: scale(6)),

                  // ===== RATING + HARGA =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: scale(12)),
                          Text(
                            " ${service.rating} (${service.totalReviews} reviews)",
                            style: TextStyle(fontSize: scale(10)),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: scale(10),
                          vertical: scale(4),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB84C),
                          borderRadius: BorderRadius.circular(scale(15)),
                        ),
                        child: Text(
                          service.basicPackage.price,
                          style: TextStyle(
                            fontSize: scale(10),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
   Widget _buildImage(String? imagePath) {
    if (imagePath != null && imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    if (imagePath != null && imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 32),
      ),
    );
  }
}
