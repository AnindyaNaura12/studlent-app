class FreelancerProfileModel {
  String name;
  String professionalStatus;
  String aboutMe;
  List<String> skills;
  List<String> certificates; // ← ganti dari portfolioImages
  String avatarPath;

  FreelancerProfileModel({
    this.name = '',
    this.professionalStatus = '',
    this.aboutMe = '',
    this.skills = const [],
    this.certificates = const [],
    this.avatarPath = 'assets/images/icons/profile.png',
  });
}