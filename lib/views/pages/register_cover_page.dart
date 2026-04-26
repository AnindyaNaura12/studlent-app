import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'register_page.dart';
import 'home_pages.dart';

class RegisterCoverPage extends StatelessWidget {
  RegisterCoverPage({super.key});

  final AuthController _controller = AuthController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Scale dengan clamp agar tidak overflow di layar kecil/besar
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          child: Stack(
            children: [
              // ================= MAIN CONTENT =================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s(24)),
                child: Column(
                  children: [
                    // Ruang untuk back button
                    SizedBox(height: s(52)),

                    const Spacer(),

                    // ================= LOGO =================
                    Image.asset(
                      'assets/images/logo_studlent.png',
                      width: s(140),
                    ),

                    SizedBox(height: s(20)),

                    // ================= TITLE =================
                    Text(
                      "Get Your Work Done\nWith Skilled Students",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: s(22),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: s(10)),

                    // ================= SUBTITLE =================
                    Text(
                      "Join Studlent and find skilled students ready\nto help with your projects",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: s(13),
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: s(24)),

                    // ================= ILLUSTRATION =================
                    // Pakai Flexible agar gambar tidak overflow di layar pendek
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.35,
                        ),
                        child: Image.asset(
                          'assets/images/cover_regist.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ================= CREATE ACCOUNT BUTTON =================
                    SizedBox(
                      width: double.infinity,
                      height: s(50),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s(12)),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: s(15),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: s(16)),
                  ],
                ),
              ),

              // ================= BACK BUTTON =================
              Positioned(
                top: s(6),
                left: s(6),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                    size: s(24),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
