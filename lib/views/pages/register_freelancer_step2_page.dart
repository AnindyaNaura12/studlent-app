import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/custom_back_button.dart';
import '../widgets/agreement_widget.dart';
import '../pages/terms_conditions_page.dart';
import '../pages/freelancer_agreement_page.dart';
import '../../controllers/freelancer_registration_controller.dart';
import '../../models/skill_model.dart';

class RegisterFreelancerStep2Page extends StatefulWidget {
  final RegistrationController controller;

  const RegisterFreelancerStep2Page({
    super.key,
    required this.controller,
  });

  @override
  State<RegisterFreelancerStep2Page> createState() =>
      _RegisterFreelancerStep2PageState();
}

class _RegisterFreelancerStep2PageState
    extends State<RegisterFreelancerStep2Page> {

  final TextEditingController _skillController = TextEditingController();

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    widget.controller.addSkill(_skillController.text);
    setState(() {});
    _skillController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD59E), Color(0xFFFFF8EE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomBackButton(
                  onTap: () => Navigator.pop(context),
                ),

                Image.asset(
                  'assets/images/logo_studlent.png',
                  width: 120,
                ),
                const SizedBox(height: 20),
                _buildCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Form(
        key: widget.controller.formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Center(
              child: Text(
                "Step 2 of 2",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // skills input
            const Text(
              "Skills",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextFormField(
              controller: _skillController,
              decoration: InputDecoration(
                hintText: "e.g. UI Design",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addSkill,
                ),
              ),
              onFieldSubmitted: (_) => _addSkill(),
            ),

            const SizedBox(height: 15),

            // skill chips
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.controller.model.selectedSkills
                  .map((skill) => _buildChip(skill))
                  .toList(),
            ),

            const SizedBox(height: 20),

            // bio
            const Text(
              "Short Bio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextFormField(
              maxLines: 3,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: "Tell about yourself...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onSaved: (v) => widget.controller.model.bio = v ?? "",
            ),

            const SizedBox(height: 10),

            AgreementWidget(
            value: widget.controller.model.agreeToTerms,
            text: "Terms & Conditions",
            onTap: (v) => setState(() {
              widget.controller.model.agreeToTerms = v;
            }),
            onLinkTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TermsConditionsPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          AgreementWidget(
            value: widget.controller.model.agreeToAgreement,
            text: "Freelancer Agreement",
            onTap: (v) => setState(() {
              widget.controller.model.agreeToAgreement = v;
            }),
            onLinkTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FreelancerAgreementPage(),
                ),
              );
            },
          ),
            const SizedBox(height: 25),

            // button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // validasi skill dulu
                  if (widget.controller.model.selectedSkills.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please add at least one skill"),
                      ),
                    );
                    return;
                  }

                  widget.controller.handleFinish(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Finish",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // chip
  Widget _buildChip(Skill skill) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.controller.removeSkill(skill.name);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(skill.name),
            const SizedBox(width: 5),
            const Icon(Icons.close, size: 16),
          ],
        ),
      ),
    );
  }

}