import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'register_page.dart';
import '../widgets/custom_back_button.dart';
import '../../controllers/auth_controller.dart';
import '../pages/home_pages.dart'; // sesuaikan path

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _controller = AuthController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    if (_loading) return; // 🔥 anti double click

    // ================= VALIDASI =================
    if (_controller.usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username wajib diisi')),
      );
      return;
    }

    if (_controller.passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password wajib diisi')),
      );
      return;
    }

    // ================= LOGIN =================
    setState(() => _loading = true);

    final error = await _controller.login();

    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // ================= SUCCESS =================
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scale(double size) => size * (screenWidth / 375);
    double s(double size) => scale(size).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD59E), Color(0xFFFFF8EE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(s(10)),
                  child: CustomBackButton(
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ),

              // LOGO
              Image.asset('assets/images/logo_studlent.png', height: s(65)),
              SizedBox(height: s(14)),

              // FORM
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: s(20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(s(40)),
                      topRight: Radius.circular(s(40)),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(s(40)),
                      topRight: Radius.circular(s(40)),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(s(24), s(30), s(24), s(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: s(22),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                children: const [
                                  TextSpan(text: 'Welcome to\n'),
                                  TextSpan(
                                    text: 'Studlent',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                  TextSpan(text: ', Login Now!'),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: s(26)),

                          // USERNAME
                          _buildLabel('Username', s),
                          _buildTextField(
                            controller: _controller.usernameController,
                            hint: 'Enter your username',
                            icon: Icons.person_outline,
                            scale: s,
                          ),

                          SizedBox(height: s(16)),

                          // PASSWORD
                          _buildLabel('Password', s),
                          _buildPasswordField(s),

                          SizedBox(height: s(24)),

                          // 🔥 BUTTON LOGIN
                          SizedBox(
                            width: double.infinity,
                            height: s(52),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(s(30)),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9800),
                                    Color(0xFFFFB74D),
                                  ],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed:
                                    _loading ? null : _onLoginPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(s(30)),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: s(17),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          SizedBox(height: s(16)),

                          // SIGN UP
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: s(13),
                                ),
                                children: [
                                  const TextSpan(
                                      text: "Don't have an account? "),
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: s(13),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double Function(double) s) {
    return Padding(
      padding: EdgeInsets.only(left: s(4), bottom: s(8)),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: s(14),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double Function(double) scale,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(scale(30)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(double Function(double) s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(s(30)),
      ),
      child: TextField(
        controller: _controller.passwordController,
        obscureText: _controller.obscureLoginPassword,
        decoration: InputDecoration(
          hintText: 'Enter your password',
          prefixIcon: const Icon(Icons.lock_outline),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              _controller.obscureLoginPassword
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              _controller.toggleLoginPasswordVisibility(
                () => setState(() {}),
              );
            },
          ),
        ),
      ),
    );
  }
}