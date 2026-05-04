import 'package:flutter/material.dart';
import '../../models/services_model.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/freelancer_card.dart';
import '../../controllers/services_controller.dart';
import 'service_detail_page.dart';

class DetailProfileFreelancer extends StatelessWidget {
  final ServiceModel service;

  final MyServicesController controller =
    MyServicesController();

  DetailProfileFreelancer({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5C2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(s(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CustomBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                  ),

                  Text(
                    "Profile Freelancer",
                    style: TextStyle(
                      fontSize: s(22),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
                        
              SizedBox(height: s(28)),

              // PROFILE IMAGE
              Center(
                child: CircleAvatar(
                  radius: s(60),
                  backgroundImage: AssetImage(
                    service.imagePath ??
                        'assets/images/placeholder.png',
                  ),
                ),
              ),

              SizedBox(height: s(18)),

              // NAME
              Center(
                child: Text(
                  service.name,
                  style: TextStyle(
                    fontSize: s(26),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: s(4)),

              // TITLE
              Center(
                child: Text(
                  service.title,
                  style: TextStyle(
                    fontSize: s(18),
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: s(10)),

              // RATING
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 20,
                    ),

                    SizedBox(width: s(4)),

                    Text(
                      "${service.rating} (${service.totalReviews})",
                      style: TextStyle(
                        fontSize: s(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: s(32)),

              // ABOUT ME
              Text(
                "About Me",
                style: TextStyle(
                  fontSize: s(24),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: s(12)),

              Text(
                service.description,
                style: TextStyle(
                  fontSize: s(14),
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: s(30)),

              // SKILLS
              Text(
                "Skills & Expertise",
                style: TextStyle(
                  fontSize: s(24),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: s(18)),

              Row(
                children: [
                  _skillChip("Programming", s),

                  SizedBox(width: s(12)),

                  _skillChip("Design", s),
                ],
              ),

              SizedBox(height: s(34)),

              // SERVICES OFFERED
              Text(
                "Services Offered",
                style: TextStyle(
                  fontSize: s(24),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: s(18)),

SizedBox(
  height: s(320),
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: [
      ServiceCard( service: service, onTap: () { controller.goToServiceDetail( context, service, ); }, ),

      SizedBox(width: s(16)),

      ServiceCard(
        service: service,
        onTap: () {
          controller.goToServiceDetail(context, service);
        },
      ),
    ],
  ),
),


              SizedBox(height: s(32)),

              // PORTFOLIO
              Text(
                "Portofolio",
                style: TextStyle(
                  fontSize: s(24),
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: s(18)),

              SizedBox(
                height: s(260),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _portfolioImage(
                      service.imagePath,
                      s,
                    ),

                    SizedBox(width: s(16)),

                    _portfolioImage(
                      service.imagePath,
                      s,
                    ),

                    SizedBox(width: s(16)),

                    _portfolioImage(
                      service.imagePath,
                      s,
                    ),
                  ],
                ),
              ),

              SizedBox(height: s(30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skillChip(
    String text,
    double Function(double) s,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: s(28),
        vertical: s(14),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD199),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: s(16),
        ),
      ),
    );
  }

  Widget _portfolioImage(
    String? imagePath,
    double Function(double) s,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(s(20)),
      child: Image.asset(
        imagePath ??
            'assets/images/placeholder.png',
        width: s(170),
        fit: BoxFit.cover,
      ),
    );
  }
}

