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

    // 🔥 SCALE SYSTEM
    double scale(double size) => size * (screenWidth / 375);

    return Scaffold(
      body: Container(
        width: double.infinity,
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
                padding: EdgeInsets.symmetric(horizontal: scale(24)),
                child: Column(
                  children: [

                    SizedBox(height: scale(20)),

                    const Spacer(),

                    // LOGO
                    Image.asset(
                      'assets/images/logo_studlent.png',
                      width: scale(140),
                    ),

                    SizedBox(height: scale(24)),

                    // TITLE
                    Text(
                      "Start Earning with\nYour Skills",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: scale(22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: scale(10)),

                    // SUBTITLE
                    Text(
                      "Join Studlent and offer your services to real clients.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: scale(13),
                        color: Colors.black54,
                      ),
                    ),

                    SizedBox(height: scale(30)),

                    // IMAGE
                    Image.asset(
                      'assets/images/cover_regist.png',
                      height: scale(260),
                      fit: BoxFit.contain,
                    ),

                    const Spacer(),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: scale(48),
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
                            borderRadius: BorderRadius.circular(scale(12)),
                          ),
                        ),
                        child: Text(
                          "Create Freelance Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: scale(14),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: scale(14)),

                    // TEXT LINK
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          "Want to become a freelancer? Start by ",
                          style: TextStyle(fontSize: scale(12)),
                        ),
                        GestureDetector(
                          onTap: () {
                            _controller.goToRegister(context);
                          },
                          child: Text(
                            "creating a user account",
                            style: TextStyle(
                              fontSize: scale(12),
                              color: const Color(0xFFFFB84C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          ".",
                          style: TextStyle(fontSize: scale(12)),
                        ),
                      ],
                    ),

                    SizedBox(height: scale(20)),
                  ],
                ),
              ),

              // ================= BACK BUTTON =================
              Positioned(
                top: scale(10),
                left: scale(10),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: scale(24),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HomePage()),
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