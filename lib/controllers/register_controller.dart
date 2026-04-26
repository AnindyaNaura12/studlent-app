import 'package:flutter/material.dart';
import '../models/register_model.dart';

class RegisterController {
  final RegisterModel model = RegisterModel();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
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

  void togglePasswordVisibility(VoidCallback refresh) {
    obscurePassword = !obscurePassword;
    refresh();
  }

  void setProductInterest(String? value, VoidCallback refresh) {
    selectedInterest = value;
    model.productInterest = value ?? '';
    refresh();
  }

  void setAgreeToTerms(bool? value, VoidCallback refresh) {
    agreeToTerms = value ?? false;
    model.agreeToTerms = agreeToTerms;
    refresh();
  }

  String? validate() {
    if (usernameController.text.trim().isEmpty) return 'Username wajib diisi';
    if (phoneController.text.trim().isEmpty) return 'Nomor HP wajib diisi';
    if (passwordController.text.trim().isEmpty) return 'Password wajib diisi';
    if (selectedInterest == null) return 'Pilih Product Interest';
    if (!agreeToTerms) return 'Anda harus menyetujui Terms & Conditions';
    return null;
  }

  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }
}