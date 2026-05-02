import 'package:flutter/material.dart';
import '../models/freelancer_profile_model.dart';

class EditProfileController {
  final FreelancerProfileModel model;

  late TextEditingController nameController;
  late TextEditingController professionalStatusController;
  late TextEditingController aboutMeController;
  late TextEditingController skillInputController;

  List<String> skills = [];
  List<String> portfolioImages = [];

  EditProfileController({FreelancerProfileModel? initialModel})
    : model = initialModel ?? FreelancerProfileModel() {
    nameController = TextEditingController(text: model.name);
    professionalStatusController = TextEditingController(
      text: model.professionalStatus,
    );
    aboutMeController = TextEditingController(text: model.aboutMe);
    skillInputController = TextEditingController();
    skills = List<String>.from(model.skills);
    portfolioImages = List<String>.from(model.portfolioImages);
  }

  void addSkill(String skill, VoidCallback refresh) {
    final trimmed = skill.trim();
    if (trimmed.isNotEmpty && !skills.contains(trimmed)) {
      skills.add(trimmed);
      skillInputController.clear();
      refresh();
    }
  }

  void removeSkill(String skill, VoidCallback refresh) {
    skills.remove(skill);
    refresh();
  }

  void addPortfolioImage(String path, VoidCallback refresh) {
    portfolioImages.add(path);
    refresh();
  }

  void removePortfolioImage(int index, VoidCallback refresh) {
    portfolioImages.removeAt(index);
    refresh();
  }

  String? validate() {
    if (nameController.text.trim().isEmpty) return 'Nama tidak boleh kosong.';
    if (professionalStatusController.text.trim().isEmpty) {
      return 'Professional Status tidak boleh kosong.';
    }
    return null;
  }

  FreelancerProfileModel save() {
    model.name = nameController.text.trim();
    model.professionalStatus = professionalStatusController.text.trim();
    model.aboutMe = aboutMeController.text.trim();
    model.skills = List<String>.from(skills);
    model.portfolioImages = List<String>.from(portfolioImages);
    return model;
  }

  void dispose() {
    nameController.dispose();
    professionalStatusController.dispose();
    aboutMeController.dispose();
    skillInputController.dispose();
  }
}
