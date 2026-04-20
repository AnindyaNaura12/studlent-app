import '../models/user_model.dart';

class ProfileController {
  bool isFreelancer = true;

  /// Data profil pengguna (nantinya bisa diambil dari API/local storage)
  UserModel getUser() {
    return UserModel(
      username: 'Sarah Angel',
      role: isFreelancer ? 'Freelancer' : 'Client',
      university: 'Universitas Brawijaya',
      specialty: 'UI/UX Design',
      avatarPath: 'assets/images/profile_user.png',
      services: 5,
      rating: 4.8,
      earned: 'Rp 2jt',
    );
  }

  /// Daftar menu profil
  List<Map<String, dynamic>> getMenuItems() {
    return [
      {'title': 'My Skills', 'hasTag': true},
      {'title': 'My Portfolio', 'hasTag': false},
      {'title': 'Create Service', 'hasTag': false},
      {'title': 'Privacy Policy', 'hasTag': false},
      {'title': 'Logout', 'hasTag': false},
    ];
  }

  void toggleRole() {
    isFreelancer = !isFreelancer;
  }

  void onMenuTap(String title) {
    // TODO: routing ke halaman masing-masing menu
    switch (title) {
      case 'Logout':
        // TODO: logout logic
        break;
      default:
        break;
    }
  }
}
