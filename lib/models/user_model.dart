class UserModel {
  final String username;
  final String role; // 'freelancer' or 'client'
  final String university;
  final String specialty;
  final String avatarPath;

  // Freelancer stats
  final int services;
  final double rating;
  final String earned;

  // Client stats
  final String email;
  final String location;
  final int myOrders;
  final String totalSpent;
  final int completedOrders;

  // Editable fields (client)
  final String name;
  final String password;

  UserModel({
    required this.username,
    required this.role,
    required this.university,
    required this.specialty,
    required this.avatarPath,
    this.services = 0,
    this.rating = 0.0,
    this.earned = 'Rp 0',
    this.email = '',
    this.location = '',
    this.myOrders = 0,
    this.totalSpent = 'Rp 0',
    this.completedOrders = 0,
    this.name = '',
    this.password = '',
  });
}