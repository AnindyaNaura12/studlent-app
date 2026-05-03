import 'package:flutter/material.dart';
import '../models/freelancer_model.dart';
import '../models/skill_model.dart';
import '../../views/pages/register_freelancer_step2_page.dart';

class RegistrationController {

  final formKeyStep1 = GlobalKey<FormState>();
  final formKeyStep2 = GlobalKey<FormState>();

  FreelancerModel model = FreelancerModel();
  List<String> bankList = ["BCA", "BRI", "BNI", "Mandiri", "CIMB"];

  String? selectedBank;

  // =============================
  // ADD SKILL (ALL CUSTOM)
  // =============================
  void addSkill(String name) {
    name = name.trim();
    if (name.isEmpty) return;

    name = name[0].toUpperCase() + name.substring(1);

    bool exists = model.selectedSkills.any(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
    );

    if (!exists) {
      model.selectedSkills.add(
        Skill(name: name, isCustom: true),
      );
    }
  }

  // =============================
  // REMOVE SKILL
  // =============================
  void removeSkill(String name) {
    model.selectedSkills.removeWhere((s) => s.name == name);
  }

  // =============================
  // STEP 1 → NEXT
  // =============================
  void handleNextStep(BuildContext context) {
    if (formKeyStep1.currentState!.validate()) {
      formKeyStep1.currentState!.save();

      print("Name: ${model.fullName}");
      print("Bank: ${model.bankName}");
      print("Rekening: ${model.accountNumber}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterFreelancerStep2Page(
            controller: this,
          ),
        ),
      );
    }
  }

  // =============================
  // FINISH
  // =============================
  void handleFinish(BuildContext context) {
    if (!model.agreeToTerms || !model.agreeToAgreement) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to all terms")),
      );
      return;
    }

    if (formKeyStep2.currentState!.validate()) {
      formKeyStep2.currentState!.save();

      print("Skills:");
      for (var s in model.selectedSkills) {
        print(s.name);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Success")),
      );
    }
  }
}