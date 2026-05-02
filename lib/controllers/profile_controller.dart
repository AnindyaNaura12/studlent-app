import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../views/pages/my_services_page.dart';
import '../views/pages/my_profile_page.dart';

class ProfileController {
  bool isFreelancer = false;

  UserModel getFreelancerUser() {
    return UserModel(
      username: 'Sarah Angel',
      name: 'Sarah Angel',
      role: 'Freelancer',
      university: 'Universitas Brawijaya',
      specialty: 'UI/UX Design',
      avatarPath: 'assets/images/freelancers/freelancer_1.png',
      email: 'sarahangel@gmail.com',
      location: 'Malang, Jawa Timur',
      services: 5,
      rating: 4.8,
      earned: 'Rp 2jt',
    );
  }

  UserModel getClientUser() {
    return UserModel(
      username: 'Sarah Angel',
      name: 'Hasbiy Fernandes',
      role: 'Client',
      university: 'Universitas Brawijaya',
      specialty: 'UI/UX Design',
      avatarPath: 'assets/images/freelancers/freelancer_1.png',
      email: 'sarahangel@gmail.com',
      location: 'Malang, Jawa Timur',
      myOrders: 5,
      totalSpent: '1jt',
      completedOrders: 3,
      password: '••••••••••••••••••',
    );
  }

  UserModel getUser() {
    return isFreelancer ? getFreelancerUser() : getClientUser();
  }

  List<Map<String, dynamic>> getFreelancerMenuItems() {
    return [
      {'title': 'My Profile', 'hasTag': true},
      {'title': 'My Portfolio', 'hasTag': false},
      {'title': 'My Orders', 'hasTag': false},
      {'title': 'My Services', 'hasTag': false}, // ← tap → MyServicesPage
      {'title': 'Logout', 'hasTag': false},
    ];
  }

  List<Map<String, dynamic>> getClientMenuItems() {
    return [
      {'title': 'Logout', 'hasTag': false},
    ];
  }

  void toggleRole() {
    isFreelancer = !isFreelancer;
  }

  void onMenuTap(String title, BuildContext context) {
    switch (title) {
      case 'My Services':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyServicesPage()),
        );
        break;
      case 'My Profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileFreelancerPage()),
        );
        break;
      case 'Logout':
        // TODO: logout logic
        break;
      default:
        break;
    }
  }
}
