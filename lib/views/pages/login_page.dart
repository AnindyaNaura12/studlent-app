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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    // TODO: navigasi ke HomePage setelah login sukses
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scale(double size) => size * (screenWidth / 375);

    // Clamp agar tidak overflow di layar sangat kecil atau sangat besar
    double s(double size) => scale(size).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      // Penting: mencegah overflow saat keyboard muncul
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(8), vertical: s(4)),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: s(24),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // ================= LOGO =================
              Image.asset('assets/images/logo_studlent.png', height: s(65)),

              SizedBox(height: s(14)),

              // ================= FORM CONTAINER =================
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: s(20),
                        offset: Offset(0, -s(5)),
                      ),
                    ],
                  ),
                  // ClipRRect mencegah konten meluber keluar rounded corner
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(s(40)),
                      topRight: Radius.circular(s(40)),
                    ),
                    child: SingleChildScrollView(
                      // ClampingScrollPhysics menghilangkan glow/garis hitam
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(s(24), s(30), s(24), s(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ================= TITLE =================
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: s(22),
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
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

                          // ================= USERNAME =================
                          _buildLabel('Username', s),
                          _buildTextField(
                            controller: _controller.usernameController,
                            hint: 'Enter your username',
                            icon: Icons.person_outline,
                            scale: s,
                          ),

                          SizedBox(height: s(16)),

                          // ================= PASSWORD =================
                          _buildLabel('Password', s),
                          _buildPasswordField(s),

                          SizedBox(height: s(24)),

                          // ================= SIGN IN BUTTON =================
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: s(10),
                                    offset: Offset(0, s(4)),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _onLoginPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(s(30)),
                                  ),
                                ),
                                child: Text(
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

                          // ================= SIGN UP LINK =================
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: s(13),
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Don't have an account? ",
                                  ),
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

                          SizedBox(height: s(8)),
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

  // ================= LABEL =================
  Widget _buildLabel(String text, double Function(double) s) {
    return Padding(
      padding: EdgeInsets.only(left: s(4), bottom: s(8)),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: s(14),
          color: Colors.black,
        ),
      ),
    );
  }

  // ================= TEXT FIELD =================
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
        style: TextStyle(fontSize: scale(14)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontSize: scale(13)),
          prefixIcon: Icon(icon, color: Colors.grey, size: scale(20)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: scale(15)),
        ),
      ),
    );
  }

  // ================= PASSWORD FIELD =================
  Widget _buildPasswordField(double Function(double) s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(s(30)),
      ),
      child: TextField(
        controller: _controller.passwordController,
        obscureText: _controller.obscureLoginPassword,
        style: TextStyle(fontSize: s(14)),
        decoration: InputDecoration(
          hintText: 'Enter your password',
          hintStyle: TextStyle(color: Colors.grey, fontSize: s(13)),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey, size: s(20)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: s(15)),
          suffixIcon: IconButton(
            icon: Icon(
              _controller.obscureLoginPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: s(20),
            ),
            onPressed: () => _controller.toggleLoginPasswordVisibility(
              () => setState(() {}),
            ),
          ),
        ),
      ),
    );
  }
}
