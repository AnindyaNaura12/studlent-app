import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/freelancer_profile_model.dart';

class EditProfileController {
  final supabase = Supabase.instance.client;
  final FreelancerProfileModel model;

  late TextEditingController nameController;
  late TextEditingController professionalStatusController;
  late TextEditingController aboutMeController;
  late TextEditingController skillInputController;

  List<String> skills = [];
  List<String> certificates = [];

  EditProfileController({FreelancerProfileModel? initialModel})
      : model = initialModel ?? FreelancerProfileModel() {
    nameController = TextEditingController(text: model.name);
    professionalStatusController =
        TextEditingController(text: model.professionalStatus);
    aboutMeController = TextEditingController(text: model.aboutMe);
    skillInputController = TextEditingController();
    skills = List<String>.from(model.skills);
    certificates = List<String>.from(model.certificates);
  }

  // ── Load dari Supabase ────────────────────────────────────
  Future<void> loadFromSupabase() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      // Ambil data user
      final user = await supabase
          .from('users')
          .select('id_user, nama')
          .eq('email', authUser.email!)
          .single();

      final idUser = user['id_user'] as int;

      // Set nama
      nameController.text = user['nama'] ?? '';

      // Ambil freelancer_profile
      final profiles = await supabase
          .from('freelancer_profiles')
          .select()
          .eq('id_user', idUser);

      if ((profiles as List).isNotEmpty) {
        final profile = profiles[0];
        professionalStatusController.text =
            profile['professional_status'] ?? '';
        aboutMeController.text = profile['bio'] ?? '';
      }

      // Ambil skills
      final skillsResult = await supabase
          .from('freelancer_skills')
          .select('skill_name')
          .eq('id_user', idUser);

      skills = (skillsResult as List)
          .map((s) => s['skill_name'] as String)
          .toList();
    } catch (e) {
      debugPrint('loadFromSupabase error: $e');
    }
  }

  // ── Save ke Supabase ──────────────────────────────────────
  Future<bool> saveToSupabase() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return false;

      final user = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .single();

      final idUser = user['id_user'] as int;

      // 1. Update nama & professional_status di tabel users
      await supabase.from('users').update({
        'nama': nameController.text.trim(),
        'professional_status': professionalStatusController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id_user', idUser);

      // 2. Upsert freelancer_profiles
      await supabase.from('freelancer_profiles').upsert({
        'id_user': idUser,
        'professional_status': professionalStatusController.text.trim(),
        'bio': aboutMeController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 3. Hapus skills lama, insert yang baru
      await supabase
          .from('freelancer_skills')
          .delete()
          .eq('id_user', idUser);

      for (final skill in skills) {
        await supabase.from('freelancer_skills').insert({
          'id_user': idUser,
          'skill_name': skill,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      debugPrint('saveToSupabase error: $e');
      return false;
    }
  }

  void addSkill(String skill, VoidCallback refresh) {
    final trimmed = skill.trim();
    if (trimmed.isNotEmpty && !skills.contains(trimmed)) {
      skills.add(trimmed);
      skillInputController.clear();
      refresh();
    }
  }

  void removeSkill(String skill, VoidCallback refresh) {
    skills.remove(skill);
    refresh();
  }

  void addCertificate(String path, VoidCallback refresh) {
    certificates.add(path);
    refresh();
  }

  void removeCertificate(int index, VoidCallback refresh) {
    certificates.removeAt(index);
    refresh();
  }

  String? validate() {
    if (nameController.text.trim().isEmpty) {
      return 'Nama tidak boleh kosong.';
    }
    if (professionalStatusController.text.trim().isEmpty) {
      return 'Professional Status tidak boleh kosong.';
    }
    return null;
  }

  void dispose() {
    nameController.dispose();
    professionalStatusController.dispose();
    aboutMeController.dispose();
    skillInputController.dispose();
  }
}