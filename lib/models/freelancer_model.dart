import 'skill_model.dart';

class FreelancerModel {
  // Step 1
  String fullName = '';
  String university = '';
  String major = '';
  String phoneNumber = '';
  String? bankName;
  String? accountNumber;
  String? accountHolder;
  String professionalStatus = ''; // ← tambah

  // Step 2
  List<Skill> selectedSkills = [];
  String bio = '';

  // Agreement
  bool agreeToTerms = false;
  bool agreeToAgreement = false;
}