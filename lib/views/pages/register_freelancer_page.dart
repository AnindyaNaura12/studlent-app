import 'package:flutter/material.dart';
import '../widgets/custom_back_button.dart';
import '../../controllers/freelancer_registration_controller.dart';

class RegisterFreelancerPage extends StatefulWidget {
  const RegisterFreelancerPage({super.key});

  @override
  State<RegisterFreelancerPage> createState() =>
      _RegisterFreelancerPageState();
}

class _RegisterFreelancerPageState
  extends State<RegisterFreelancerPage> {

  final RegistrationController _controller = RegistrationController();

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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _controller.formKeyStep1,
                  child: Column(
                    children: [
                      CustomBackButton(
                        onTap: () => Navigator.pop(context),
                      ),

                      Image.asset(
                        'assets/images/logo_studlent.png',
                        width: 150,
                      ),
                      const SizedBox(height: 30),
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Center(
            child: Text(
              "Step 1 of 2",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 25),

          _buildLabel("Full Name"),
          _buildTextField(
            hint: "Enter your full name",
            onSaved: (v) => _controller.model.fullName = v!,
          ),

          _buildLabel("University"),
          _buildTextField(
            hint: "e.g. Politeknik Negeri Malang",
            onSaved: (v) => _controller.model.university = v!,
          ),

          _buildLabel("Major"),
          _buildTextField(
            hint: "e.g. Informatics Engineering",
            onSaved: (v) => _controller.model.major = v!,
          ),

          _buildLabel("Phone Number"),
          _buildTextField(
            hint: "+621234567890",
            keyboardType: TextInputType.phone,
            onSaved: (v) => _controller.model.phoneNumber = v!,
          ),

          _buildLabel("Bank Account"),
          _buildTextField(
            hint: "Bank name & account number",
            onSaved: (v) => _controller.model.bankAccount = v!,
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () =>
                  _controller.handleNextStep(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Next",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 15),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  Widget _buildTextField({
    TextInputType? keyboardType,
    required Function(String?) onSaved,
    required String hint,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: (value) =>
          value!.isEmpty ? "Field ini wajib diisi" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}