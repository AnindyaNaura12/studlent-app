import 'package:flutter/material.dart';
import '/controllers/services_controller.dart';
import '/controllers/home_controller.dart';
import '/models/services_model.dart';
import '../widgets/categori_item.dart';
import '../widgets/freelancer_card.dart';
import '../widgets/freelancer_card_horizontal.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int selectedIndex = 0;

  final controller = HomeController();

  @override
  Widget build(BuildContext context) {
    List<ServiceModel> services = ServiceController.getServices();
    final controller = HomeController();
    final categories = controller.getCategories();


    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              // HEADER
              const Text(
                "Hi, Nafila 👋",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text("Find the right student service for you"),

              const SizedBox(height: 20),

              // SEARCH
              TextField(
                decoration: InputDecoration(
                  hintText: "What you're looking for?",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // CATEGORY
              const Text(
                "Service Categories",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(categories.length, (index) {
                    final cat = categories[index];

                    return CategoryItem(
                      title: cat.title,
                      iconPath: cat.iconPath,
                      isSelected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // RECOMMEND
              const Text(
                "Recommended For You",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return FreelancerCardHorizontal(
                    service: services[index],
                  );
                },
              ),

              const SizedBox(height: 5),

              // POPULAR
              const Text(
                "Popular Services",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return ServiceCard(
                      service: services[index],
                    );
                  },
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}