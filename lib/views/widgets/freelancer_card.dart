import 'package:flutter/material.dart';
import '/models/services_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: s(180),
        margin: EdgeInsets.only(right: s(14), bottom: s(4)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: s(10),
              offset: Offset(0, s(3)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE =================
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(s(16))),
              child: SizedBox(
                height: s(120),
                width: double.infinity,
                child: _buildImage(service, s),
              ),
            ),

            // ================= INFO =================
            Padding(
              padding: EdgeInsets.fromLTRB(s(12), s(10), s(12), s(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TITLE SERVICE =================
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: s(12),
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: s(2)),

                  // ================= CATEGORY =================
                  Text(
                    service.category.isNotEmpty ?  service.category : 'General',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: s(10),
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ================= NAME + RATING =================
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: s(13),
                            color: const Color(0xFFFFB74D),
                          ),
                        ),
                      ),
                      SizedBox(width: s(4)),
                      Icon(Icons.star, color: Colors.orange, size: s(12)),
                      SizedBox(width: s(2)),
                      Text(
                        '${service.rating}',
                        style: TextStyle(
                          fontSize: s(10),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: s(4)),

                  // ================= SHORT DESCRIPTION =================
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: s(10),
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: s(4)),

                  // ================= UNIVERSITY =================
                  Text(
                    service.university,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: s(10), color: Colors.grey[600]),
                  ),

                  SizedBox(height: s(10)),

                  // ================= PRICE BUTTON =================
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: s(8)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D),
                      borderRadius: BorderRadius.circular(s(20)),
                    ),
                    child: Text(
                      service.basicPackage.price,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: s(12),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ServiceModel service, double Function(double) s) {
    final url = service.imagePath != null &&
            service.imagePath!.startsWith('http')
        ? service.imagePath!
        : service.serviceImages.isNotEmpty &&
                service.serviceImages.first.startsWith('http')
            ? service.serviceImages.first
            : null;

    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: s(120),
        errorBuilder: (_, __, ___) => _placeholder(s),
      );
    }
    return _placeholder(s);
  }

  Widget _placeholder(double Function(double) s) {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      height: s(120),
      child: Icon(Icons.image, size: s(40), color: Colors.grey),
    );
  }
}