import 'package:flutter/material.dart';
import '../views/pages/register_cover_page.dart';
import '../views/pages/register_page.dart';
import '../views/pages/login_page.dart';

class AuthController {
  // ── Controllers ──────────────────────────────────────────
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // ── Register extras ───────────────────────────────────────
  bool obscurePassword = true;
  bool obscureLoginPassword = true;
  String? selectedInterest;
  bool agreeToTerms = false;

  final List<String> productInterests = [
    'Website Development',
    'Mobile Development',
    'Graphic Design',
    'Write & Translation',
    'Digital Marketing',
    'Video & Animation',
  ];

  // ── Visibility Toggles ────────────────────────────────────
  void togglePasswordVisibility(VoidCallback refresh) {
    obscurePassword = !obscurePassword;
    refresh();
  }

  void toggleLoginPasswordVisibility(VoidCallback refresh) {
    obscureLoginPassword = !obscureLoginPassword;
    refresh();
  }

  // ── Setters ───────────────────────────────────────────────
  void setProductInterest(String? value, VoidCallback refresh) {
    selectedInterest = value;
    refresh();
  }

  void setAgreeToTerms(bool? value, VoidCallback refresh) {
    agreeToTerms = value ?? false;
    refresh();
  }

  // ── Login ─────────────────────────────────────────────────
  String? login() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) return 'Username tidak boleh kosong.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';

    // TODO: integrasikan dengan API / backend autentikasi
    return null;
  }

  // ── Register ──────────────────────────────────────────────
  String? register() {
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) return 'Username tidak boleh kosong.';
    if (phone.isEmpty) return 'Nomor HP tidak boleh kosong.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (selectedInterest == null) return 'Pilih Product Interest.';
    if (!agreeToTerms) return 'Anda harus menyetujui Terms & Conditions.';

    // TODO: integrasikan dengan API / backend registrasi
    return null;
  }

  // ── Dispose ───────────────────────────────────────────────
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
  }

  // ── Navigasi ──────────────────────────────────────────────
  void goToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  void goToRegisterCover(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterCoverPage()),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}