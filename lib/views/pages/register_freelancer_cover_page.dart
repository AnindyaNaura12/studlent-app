import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'register_freelancer_page.dart';
import 'login_page.dart';
import '../widgets/custom_back_button.dart';

class RegisterFreelancerCoverPage extends StatelessWidget {
  const RegisterFreelancerCoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: s(52)),

                    // ================= LOGO =================
                    Image.asset(
                      'assets/images/logo_studlent.png',
                      width: s(160),
                    ),

                    SizedBox(height: s(20)),

                    // ================= TITLE =================
                    Text(
                      "Offer Your Skills,\nEarn as a Freelancer",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: s(24),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.35,
                      ),
                    ),

                    SizedBox(height: s(10)),

                    // ================= SUBTITLE =================
                    Text(
                      "Join Studlent as a freelancer and start\nearning from your skills today",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: s(13),
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: s(20)),

                    // ================= ILLUSTRATION =================
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: s(10)),
                        child: Image.asset(
                          'assets/images/cover_regist.png',
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),

                    SizedBox(height: s(24)),

                    // ================= JOIN BUTTON =================
                    SizedBox(
                      width: double.infinity,
                      height: s(52),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(s(14)),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF9800),
                              Color(0xFFFFB74D),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterFreelancerPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(s(14)),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Join as Freelancer",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: s(16),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: s(16)),

                    // ================= LOGIN LINK =================
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: s(13),
                          ),
                          children: [
                            const TextSpan(text: 'Already a Freelancer? '),
                            TextSpan(
                              text: 'Login',
                              style: const TextStyle(
                                color: Color(0xFFFFB84C),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(
                                        isFromFreelancerCover: true,
                                      ),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: s(24)),
                  ],
                ),
              ),

              // ================= BACK BUTTON =================
              Positioned(
                top: s(6),
                left: s(6),
                child: CustomBackButton(
                  onTap: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}