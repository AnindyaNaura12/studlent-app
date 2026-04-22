import '/models/services_model.dart';

class ServiceController {
  static List<ServiceModel> getServices() {
    return [
      ServiceModel(
        name: "Carla",
        university: "Politeknik Negeri Malang",
        skills: "Java, CSS, UI Design",
        rating: 4.9,
        totalReviews: 200,
        price: "Rp 250.000",
        imagePath: "assets/images/freelancers/freelancer_1.png",
        experience: '2 years of experience',
      ),
      ServiceModel(
        name: "Jessica",
        university: "Universitas Brawijaya",
        skills: "Flutter, Firebase",
        rating: 4.8,
        totalReviews: 180,
        price: "Rp 300.000",
        imagePath: "assets/images/freelancers/freelancer_2.png",
        experience: '2 years of experience',
      ),
      ServiceModel(
        name: 'Reza',
        rating: 4.8,
        totalReviews: 150,
        experience: '2 years of experience',
        skills: 'Python, UI/UX',
        university: 'Universitas Negeri Malang',
        price: 'Rp. 175.000',
        imagePath: 'assets/images/freelancers/freelancer_3.png',
      ),
    ];
  }
}