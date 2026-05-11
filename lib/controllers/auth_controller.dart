// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/pages/register_cover_page.dart';
import '../views/pages/register_page.dart';
import '../views/pages/login_page.dart';
import '../models/services_model.dart'; // ← untuk goToLogin redirect

class AuthController {
  final supabase = Supabase.instance.client;

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

  // ── Register ──────────────────────────────────────────────
  Future<String?> register() async {
    final username = usernameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    // Generate email otomatis dari username
    final email =
        '${username.toLowerCase().replaceAll(' ', '')}@studlent.com';

    if (username.isEmpty) return 'Username tidak boleh kosong.';
    if (phone.isEmpty) return 'Nomor HP tidak boleh kosong.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (selectedInterest == null) return 'Pilih Product Interest.';
    if (!agreeToTerms) return 'Anda harus menyetujui Terms & Conditions.';

    try {
      // 1. Register ke Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) return 'Registrasi gagal, coba lagi.';

      // 2. Simpan data ke tabel users
      await supabase.from('users').insert({
        'nama': username,
        'username': username,
        'email': email,
        'password': password,
        'no_hp': phone,
        'role': 'client',
        'product_interest': selectedInterest,
      });

      return null; // null = sukses
    } catch (e) {
      return e.toString();
    }
  }

  // ── Login ─────────────────────────────────────────────────
  Future<String?> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) return 'Username tidak boleh kosong.';
    if (password.isEmpty) return 'Password tidak boleh kosong.';

    // Generate email dari username
    final email =
        '${username.toLowerCase().replaceAll(' ', '')}@studlent.com';

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return 'Login gagal, cek username dan password.';
      }

      return null; // null = sukses
    } catch (e) {
      return e.toString();
    }
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

  // ← DIUPDATE: tambah parameter opsional redirectToService
  void goToLogin(BuildContext context, {ServiceModel? redirectToService}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(redirectToService: redirectToService),
      ),
    );
  }
}