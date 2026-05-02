class FreelancerProfileModel {
  String name;
  String professionalStatus;
  String aboutMe;
  List<String> skills;
  List<String> portfolioImages;
  String avatarPath;

  FreelancerProfileModel({
    this.name = 'Carla Park',
    this.professionalStatus = 'UI/UX Design',
    this.aboutMe =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    this.skills = const ['Design', 'Programming', 'Tutoring'],
    this.portfolioImages = const [],
    this.avatarPath = 'assets/images/freelancers/freelancer_1.png',
  });
}
