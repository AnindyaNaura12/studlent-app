import 'package:flutter/material.dart';
import '/models/services_model.dart';

class FreelancerCardHorizontal extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const FreelancerCardHorizontal({super.key, required this.service, this.onTap,});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM
    double scale(double size) => size * (screenWidth / 375);

<<<<<<< HEAD
    return Container(
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
            child: Image.asset(
              // FIX: Menangani null dengan '??'
              service.imagePath ?? 'assets/images/placeholder.png',
              width: scale(90),
              height: scale(90),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: scale(90),
                height: scale(90),
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
=======
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
        ClipRRect(
          borderRadius: BorderRadius.circular(scale(14)),
          child: Image.asset(
            service.imagePath,
            width: scale(90),
            height: scale(90),
            fit: BoxFit.cover,
>>>>>>> d3e82f448ac0a138fd59b06fcc306b6f52dfbe60
          ),
        ),

        SizedBox(width: scale(12)),

<<<<<<< HEAD
          // ================= CONTENT =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORY
                Text(
                  service.category.isNotEmpty ? service.category : "General",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scale(13),
=======
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Video Editing",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: scale(13),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

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

              Text(
                service.skills,
                style: TextStyle(fontSize: scale(10), color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: scale(4)),

              Text(
                service.university,
                style: TextStyle(fontSize: scale(10)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: scale(6)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: scale(12)),
                      Text(
                        " ${service.rating} (${service.totalReviews})",
                        style: TextStyle(fontSize: scale(10)),
                      ),
                    ],
>>>>>>> d3e82f448ac0a138fd59b06fcc306b6f52dfbe60
                  ),

<<<<<<< HEAD
                // NAME
                Text(
                  service.name.isNotEmpty ? service.name : service.title,
                  style: TextStyle(
                    color: const Color(0xFFFFB84C),
                    fontWeight: FontWeight.bold,
                    fontSize: scale(12),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // SKILLS
                Text(
                  service.skills.isNotEmpty
                      ? service.skills
                      : "No skills listed",
                  style: TextStyle(fontSize: scale(10), color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: scale(4)),

                // UNIVERSITY
                Text(
                  service.university.isNotEmpty ? service.university : "No uni",
                  style: TextStyle(fontSize: scale(10)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: scale(6)),

                // ================= BOTTOM ROW =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // RATING
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: scale(12)),
                        Text(
                          " ${service.rating} (${service.totalReviews})",
                          style: TextStyle(fontSize: scale(10)),
                        ),
                      ],
                    ),

                    // PRICE
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
                        // FIX: Mengakses harga dari basicPackage
                        service.basicPackage.price.isNotEmpty
                            ? service.basicPackage.price
                            : "Contact",
                        style: TextStyle(
                          fontSize: scale(10),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
=======
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
                      "${service.price}",
                      style: TextStyle(
                        fontSize: scale(10),
                        fontWeight: FontWeight.bold,
>>>>>>> d3e82f448ac0a138fd59b06fcc306b6f52dfbe60
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
}
