import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'register_page.dart';
import 'home_pages.dart';

class RegisterCoverPage extends StatelessWidget {
  RegisterCoverPage({super.key});

  final AuthController _controller = AuthController();

  @override
  Widget build(BuildContext context) {
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

            // ===================== MAIN CONTENT =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Spacer(),

                  Image.asset(
                    'assets/images/logo_studlent.png',
                    width: 160,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Start Earning with\nYour Skills",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Join Studlent and offer your services to real clients.",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 35),

                  Image.asset(
                    'assets/images/cover_regist.png',
                    height: 350,
                    fit: BoxFit.contain,
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Create Freelance Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text("Want to become a freelancer? Start by "),
                      GestureDetector(
                        onTap: () {
                          _controller.goToRegister(context);
                        },
                        child: const Text(
                          "creating a user account",
                          style: TextStyle(
                            color: Color(0xFFFFB84C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text("."),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ===================== BACK BUTTON =====================
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
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