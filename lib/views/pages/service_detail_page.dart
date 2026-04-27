import 'package:flutter/material.dart';
import '../../models/services_model.dart';

class ServiceDetailPage extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  int selectedTab = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    final service = widget.service;

    String title;
    String desc;
    String price;

    switch (selectedTab) {
      case 0:
        title = "Basic Package";
        desc = "1 Concept + JPG File";
        price = "Rp 150.000";
        break;
      case 1:
        title = "Standard Package";
        desc = "2 Concepts + Vector Files + Favicon";
        price = service.price;
        break;
      case 2:
        title = "Premium Package";
        desc = "3 Concepts + All Files + Source + Priority";
        price = "Rp 500.000";
        break;
      default:
        title = "";
        desc = "";
        price = "";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(s(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),

                    SizedBox(height: s(6)),

                    Text(
                      "UI/UX Design for Mobile App",
                      style: TextStyle(
                        fontSize: s(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: s(6)),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: s(4)),
                        Text(
                          "${service.rating} (${service.totalReviews})",
                          style: TextStyle(fontSize: s(12)),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: s(10), vertical: s(4)),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Mobile App",
                            style: TextStyle(fontSize: s(10)),
                          ),
                        )
                      ],
                    ),

                    SizedBox(height: s(16)),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(s(16)),
                      child: Image.asset(
                        service.imagePath,
                        width: double.infinity,
                        height: s(180),
                        fit: BoxFit.cover,
                      ),
                    ),

                    SizedBox(height: s(16)),

                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(service.imagePath),
                          radius: s(20),
                        ),
                        SizedBox(width: s(10)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: s(13),
                              ),
                            ),
                            SizedBox(height: s(2)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: s(10),
                                vertical: s(4),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA726),
                                borderRadius: BorderRadius.circular(s(20)),
                              ),
                              child: Text(
                                "View Profile",
                                style: TextStyle(
                                  fontSize: s(10),
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: s(20)),

                    Text(
                      "Package Pricing",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: s(14),
                      ),
                    ),

                    SizedBox(height: s(10)),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(s(20)),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          _tab("Basic", 0, s),
                          _tab("Standard", 1, s),
                          _tab("Premium", 2, s),
                        ],
                      ),
                    ),

                    SizedBox(height: s(12)),

                    Container(
                      padding: EdgeInsets.all(s(12)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEED9B7),
                        borderRadius: BorderRadius.circular(s(14)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: s(12),
                            ),
                          ),
                          SizedBox(height: s(4)),
                          Text(
                            price,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: s(14),
                            ),
                          ),
                          SizedBox(height: s(4)),
                          Text(
                            desc,
                            style: TextStyle(fontSize: s(11)),
                          ),
                          Text(
                            "Delivery: 4 Days",
                            style: TextStyle(fontSize: s(11)),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: s(20)),

                    Text(
                      "About This Service",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: s(14),
                      ),
                    ),

                    SizedBox(height: s(8)),

                    Text(
                      "Professional UI/UX design for mobile applications with modern and user-friendly interface.",
                      style: TextStyle(
                        fontSize: s(12),
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.all(s(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: s(10),
                  )
                ],
              ),
              child: Row(
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: s(16),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFA726),
                      side: const BorderSide(color: Color(0xFFFFA726)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Chat Seller"),
                  ),
                  SizedBox(width: s(10)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Order Now"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tab(String text, int index, double Function(double) s) {
    final isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: s(10)),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFA726) : Colors.transparent,
            borderRadius: BorderRadius.circular(s(20)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: s(12),
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}