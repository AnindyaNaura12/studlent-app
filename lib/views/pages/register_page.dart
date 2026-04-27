import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/custom_back_button.dart';
import 'register_cover_page.dart';
import 'terms_conditions_page.dart';
import '../widgets/agreement_widget.dart';
import '../../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController _controller = AuthController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_controller.usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username wajib diisi')),
      );
      return;
    }
    if (_controller.phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor HP wajib diisi')),
      );
      return;
    }
    if (_controller.passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password wajib diisi')),
      );
      return;
    }
    if (_controller.selectedInterest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Product Interest')),
      );
      return;
    }
    if (!_controller.agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui Terms & Conditions')),
      );
      return;
    }

    final error = _controller.register();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // Navigasi ke login setelah register sukses
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB74D), Color(0xFFFFE0B2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ================= BACK BUTTON =================
              CustomBackButton(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterCoverPage()),
                    (route) => false,
                  );
                },
              ),

              // ================= LOGO =================
              Image.asset('assets/images/logo_studlent.png', height: 70),
              const SizedBox(height: 24),

              // ================= FORM CONTAINER =================
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                        // ================= TITLE =================
                        const Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ================= USERNAME =================
                        _buildLabel('Username'),
                        _buildTextField(
                          controller: _controller.usernameController,
                          hint: 'Hasbiy Fernandes',
                        ),
                        const SizedBox(height: 18),

                        // ================= MOBILE NUMBER =================
                        _buildLabel('Mobile Number'),
                        _buildTextField(
                          controller: _controller.phoneController,
                          hint: '+621234567890',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 18),

                        // ================= PASSWORD =================
                        _buildLabel('Password'),
                        _buildPasswordField(),
                        const SizedBox(height: 18),

                        // ================= PRODUCT INTEREST =================
                        _buildLabel('Product Interest'),
                        _buildDropdownField(),
                        const SizedBox(height: 20),

                        // ================= TERMS & CONDITIONS =================
                        AgreementWidget(
                          value: _controller.agreeToTerms,
                          onTap: (val) => setState(() {
                            _controller.agreeToTerms = val;
                          }),
                          text: "Terms & Conditions",
                          onLinkTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TermsConditionsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // ================= CREATE ACCOUNT BUTTON =================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _onRegisterPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ================= SIGN IN LINK =================
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign In',
                                  style: const TextStyle(
                                    color: Color(0xFFFFB84C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _controller.goToLogin(context);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= LABEL =================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ================= PASSWORD FIELD =================
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _controller.passwordController,
        obscureText: _controller.obscurePassword,
        decoration: InputDecoration(
          hintText: '••••••••••••••••••',
          hintStyle: const TextStyle(color: Colors.grey, letterSpacing: 2),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _controller.obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
            ),
            onPressed: () => _controller.togglePasswordVisibility(
              () => setState(() {}),
            ),
          ),
        ),
      ),
    );
  }

  // ================= DROPDOWN FIELD =================
  Widget _buildDropdownField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _controller.selectedInterest,
          hint: const Text(''),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _controller.productInterests.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) => _controller.setProductInterest(
            val,
            () => setState(() {}),
          ),
        ),
      ),
    );
  }
}