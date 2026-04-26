import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../controllers/auth_controller.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _controller = AuthController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final error = _controller.login();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM
    double scale(double size) => size * (screenWidth / 375);

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
        child: Column(
          children: [
            SizedBox(height: scale(50)),

            // ================= BACK BUTTON =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scale(16)),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: scale(24),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // ================= LOGO =================
            Image.asset(
              'assets/images/logo_studlent.png',
              height: scale(60),
            ),

            SizedBox(height: scale(20)),

            // ================= FORM CONTAINER =================
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: scale(20)),
                padding: EdgeInsets.all(scale(24)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(scale(30)),
                    topRight: Radius.circular(scale(30)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: scale(20),
                      offset: Offset(0, -scale(5)),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ================= TITLE =================
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: scale(20),
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: Colors.black,
                            ),
                            children: const [
                              TextSpan(text: "Welcome to\n"),
                              TextSpan(
                                text: "Studlent",
                                style: TextStyle(color: Colors.orange),
                              ),
                              TextSpan(text: ", Login Now!"),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: scale(30)),

                      _buildLabel("Username", scale),
                      _buildTextField(
                        controller: _controller.usernameController,
                        hint: "Enter your username",
                        icon: Icons.person,
                        scale: scale,
                      ),

                      SizedBox(height: scale(16)),

                      _buildLabel("Password", scale),
                      _buildTextField(
                        controller: _controller.passwordController,
                        hint: "Enter your password",
                        icon: Icons.lock,
                        isPassword: true,
                        scale: scale,
                      ),

                      SizedBox(height: scale(20)),

                      // ================= BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        height: scale(50),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(scale(30)),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: scale(10),
                                offset: Offset(0, scale(4)),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(scale(30)),
                              ),
                            ),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scale(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: scale(16)),

                      // ================= REGISTER =================
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: scale(12),
                            ),
                            children: [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: scale(12),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RegisterPage(),
                                      ),
                                    );
                                  },
                              ),
                            ],
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

  // ================= LABEL =================
  Widget _buildLabel(String text, double Function(double) scale) {
    return Padding(
      padding: EdgeInsets.only(left: scale(6), bottom: scale(6)),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: scale(13),
        ),
      ),
    );
  }

  // ================= TEXTFIELD =================
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double Function(double) scale,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(scale(25)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(fontSize: scale(13)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: scale(12)),
          prefixIcon: Icon(icon, color: Colors.grey, size: scale(18)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: scale(14),
          ),
        ),
      ),
    );
  }
}