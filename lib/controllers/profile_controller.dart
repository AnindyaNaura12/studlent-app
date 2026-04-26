import '../models/user_model.dart';

class ProfileController {
  bool isFreelancer = false; // default: user baru = Client

  /// Data profil pengguna freelancer
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

  /// Data profil pengguna client
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

  /// Menu freelancer
  List<Map<String, dynamic>> getFreelancerMenuItems() {
    return [
      {'title': 'My Skills', 'hasTag': true},
      {'title': 'My Portfolio', 'hasTag': false},
      {'title': 'Create Service', 'hasTag': false},
      {'title': 'Privacy Policy', 'hasTag': false},
      {'title': 'Logout', 'hasTag': false},
    ];
  }

  /// Menu client
  List<Map<String, dynamic>> getClientMenuItems() {
    return [
      {'title': 'Privacy Policy', 'hasTag': false},
      {'title': 'Logout', 'hasTag': false},
    ];
  }

  void toggleRole() {
    isFreelancer = !isFreelancer;
  }

  void onMenuTap(String title) {
    switch (title) {
      case 'Logout':
        // TODO: logout logic
        break;
      default:
        break;
    }
  }
}