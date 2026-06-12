import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/freelancer_model.dart';
import '../models/skill_model.dart';
import '../views/pages/register_freelancer_step2_page.dart';
import '../views/pages/home_pages.dart';
import 'profile_controller.dart';

class RegistrationController {
  final supabase = Supabase.instance.client;

  final formKeyStep1 = GlobalKey<FormState>();
  final formKeyStep2 = GlobalKey<FormState>();

  FreelancerModel model = FreelancerModel();
  List<String> bankList = ["BCA", "BRI", "BNI", "Mandiri", "CIMB"];
  String? selectedBank;

  // ── Add Skill ──────────────────────────────────────────────
  void addSkill(String name) {
    name = name.trim();
    if (name.isEmpty) return;
    name = name[0].toUpperCase() + name.substring(1);
    final exists = model.selectedSkills.any(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
    );
    if (!exists) {
      model.selectedSkills.add(Skill(name: name, isCustom: true));
    }
  }

  // ── Remove Skill ───────────────────────────────────────────
  void removeSkill(String name) {
    model.selectedSkills.removeWhere((s) => s.name == name);
  }

  // ── Step 1 → Next ──────────────────────────────────────────
  void handleNextStep(BuildContext context) {
    if (formKeyStep1.currentState!.validate()) {
      formKeyStep1.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterFreelancerStep2Page(controller: this),
        ),
      );
    }
  }

  // ── Finish → Simpan ke Supabase ────────────────────────────
  Future<void> handleFinish(BuildContext context) async {
    if (!model.agreeToTerms || !model.agreeToAgreement) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Setujui semua syarat terlebih dahulu")),
      );
      return;
    }

    if (!formKeyStep2.currentState!.validate()) return;
    formKeyStep2.currentState!.save();

    if (model.selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tambahkan minimal satu skill")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) throw Exception('User tidak ditemukan');

      // 1. Ambil id_user dari tabel users
      final userResult = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .single();

      final idUser = userResult['id_user'] as int;

      // 2. Update user — flag is_freelancer = true, role TIDAK diubah
      await supabase.from('users').update({
        'is_freelancer'      : true,
        'professional_status': model.professionalStatus,
        'nama'               : model.fullName,
        'no_hp'              : model.phoneNumber,
        'updated_at'         : DateTime.now().toIso8601String(),
      }).eq('id_user', idUser);

      // 3. Insert ke freelancer_profiles
      await supabase.from('freelancer_profiles').upsert({
        'id_user'            : idUser,
        'professional_status': model.professionalStatus,
        'universitas'        : model.university,
        'jurusan'            : model.major,
        'bio'                : model.bio,
        'no_rekening'        : model.accountNumber,
        'bank_name'          : model.bankName,
        'created_at'         : DateTime.now().toIso8601String(),
        'updated_at'         : DateTime.now().toIso8601String(),
      });

      // 4. Insert skills ke freelancer_skills
      for (final skill in model.selectedSkills) {
        await supabase.from('freelancer_skills').insert({
          'id_user'   : idUser,
          'skill_name': skill.name,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // 5. Buat wallet untuk freelancer
      await supabase.from('freelancer_wallet').upsert({
        'id_user'   : idUser,
        'balance'   : 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (context.mounted) Navigator.pop(context); // tutup loading

      if (context.mounted) {
        ProfileController.unlockFreelancer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content        : Text('Selamat! Kamu sekarang terdaftar sebagai freelancer 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // tutup loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content        : Text('Gagal mendaftar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}