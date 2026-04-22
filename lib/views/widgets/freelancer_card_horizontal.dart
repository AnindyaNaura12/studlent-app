import 'package:flutter/material.dart';
import '/models/services_model.dart';

class FreelancerCardHorizontal extends StatelessWidget {
  final ServiceModel service;

  const FreelancerCardHorizontal({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(service.imagePath, width: 100, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Video Editing", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), // Hardcoded sesuai desain
                Text(service.name, style: TextStyle(color: Color(0xFFFFB84C), fontWeight: FontWeight.bold)),
                Text(service.skills, style: TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2),
                const SizedBox(height: 5),
                Text(service.university, style: TextStyle(fontSize: 11)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(" ${service.rating} (${service.totalReviews})", style: TextStyle(fontSize: 11)),
                    ]),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Color(0xFFFFB84C), borderRadius: BorderRadius.circular(15)),
                      child: Text("Rp ${service.price}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}