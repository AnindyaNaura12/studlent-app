import 'package:flutter/material.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        //BACKGROUND
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB74D), Color(0xFFFFE0B2)],
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 60),

            // 🔵 LOGO
            Image.asset(
              'assets/images/logo_studlent.png',
              height: 70,
            ),

            const SizedBox(height: 30),

            // 🔵 REGISTER CARD
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),

                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // 🔥 TITLE
                      const Center(
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔵 USERNAME
                      _buildLabel("Username"),
                      _buildTextField(hint: "Enter your username"),

                      const SizedBox(height: 20),

                      // 🔵 Phone Number
                      _buildLabel("Phone Number"),
                      _buildTextField(hint: "Enter your phone number"),

                      const SizedBox(height: 20),

                      // 🔵 PASSWORD
                      _buildLabel("Password"),
                      _buildTextField(
                        hint: "Enter your password",
                        isPassword: true,
                        suffixIcon: Icons.visibility_off,
                      ),

                      const SizedBox(height: 35),

                      // BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: proses register
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔵 BACK TO LOGIN
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Already have an account? Sign In",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔵 LABEL
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  // 🔵 TEXT FIELD
  Widget _buildTextField({
    required String hint,
    bool isPassword = false,
    IconData? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          suffixIcon:
              suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
        ),
      ),
    );
  }
}