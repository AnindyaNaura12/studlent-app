class UserModel {
  final String username;
  final String role; // 'freelancer' or 'client'
  final String university;
  final String specialty;
  final String avatarPath;
  final int services;
  final double rating;
  final String earned;

  UserModel({
    required this.username,
    required this.role,
    required this.university,
    required this.specialty,
    required this.avatarPath,
    this.services = 0,
    this.rating = 0.0,
    this.earned = 'Rp 0',
  });
}
