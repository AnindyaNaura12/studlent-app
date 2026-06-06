class FreelancerProfileModel {
  String name;
  String professionalStatus;
  String aboutMe;
  List<String> skills;
  List<String> certificates; // URL dari supabase (DIUBAH: dulu local path, sekarang URL)
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