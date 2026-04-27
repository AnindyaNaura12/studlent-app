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
          ),
        ),

        SizedBox(width: scale(12)),

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
                      "${service.price}",
                      style: TextStyle(
                        fontSize: scale(10),
                        fontWeight: FontWeight.bold,
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
