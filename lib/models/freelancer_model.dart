import 'skill_model.dart';

class FreelancerModel {
  // STEP 1
  String fullName = '';
  String university = '';
  String major = '';
  String phoneNumber = '';
  String? bankName;
  String? accountNumber;
  String? accountHolder;

  // STEP 2
  List<Skill> selectedSkills = [];
  String bio = '';

  // Upload
  List<String> portfolioPaths = [];

  // Agreement
  bool agreeToTerms = false;
  bool agreeToAgreement = false;
}