import 'package:flutter/material.dart';
import '../views/pages/register_cover_page.dart';
import '../views/pages/register_page.dart';
import '../views/pages/login_page.dart';

class AuthController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  /// Validasi dan proses login.
  /// Kembalikan pesan error, atau null jika sukses.
  String? login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) return 'Username tidak boleh kosong.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';

    // TODO: integrasikan dengan API / backend autentikasi
    return null; // sukses
  }

  /// Validasi dan proses register.
  /// Kembalikan pesan error, atau null jika sukses.
  String? register() {
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) return 'Username tidak boleh kosong.';
    if (phone.isEmpty) return 'Nomor HP tidak boleh kosong.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';
    if (password.length < 6) return 'Password minimal 6 karakter.';

    // TODO: integrasikan dengan API / backend registrasi
    return null; // sukses
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
  }

  void goToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void goToRegisterCover(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterCoverPage(),
      ),
    );
  }

  void goToLogin(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );
}
}
