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
  List<String> certificates =
      []; // DIUBAH: sekarang menyimpan URL dari supabase
  // DITAMBAH: menyimpan data sertifikat lengkap {id, url, name}
  List<Map<String, dynamic>> certificateData = [];

  EditProfileController({FreelancerProfileModel? initialModel})
    : model = initialModel ?? FreelancerProfileModel() {
    nameController = TextEditingController(text: model.name);
    professionalStatusController = TextEditingController(
      text: model.professionalStatus,
    );
    aboutMeController = TextEditingController(text: model.aboutMe);
    skillInputController = TextEditingController();
    skills = List<String>.from(model.skills);
    certificates = List<String>.from(model.certificates);
  }

  Future<void> loadFromSupabase() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) return;

      final user = await supabase
          .from('users')
          .select('id_user, nama')
          .eq('email', authUser.email!)
          .single();

      final idUser = user['id_user'] as int;
      nameController.text = user['nama'] ?? '';

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

      final skillsResult = await supabase
          .from('freelancer_skills')
          .select('skill_name')
          .eq('id_user', idUser);

      skills = (skillsResult as List)
          .map((s) => s['skill_name'] as String)
          .toList();

      // DITAMBAH: load sertifikat dari supabase
      final certsResult = await supabase
          .from('freelancer_certificates')
          .select()
          .eq('id_user', idUser)
          .order('created_at', ascending: false);

      certificateData = List<Map<String, dynamic>>.from(certsResult);
      certificates = certificateData
          .map((c) => c['file_url'] as String)
          .toList();
    } catch (e) {
      debugPrint('loadFromSupabase error: $e');
    }
  }

  Future<bool> saveToSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;

      if (authUser == null || authUser.email == null) {
        debugPrint('saveToSupabase: user belum login');
        return false;
      }

      final userData = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .single();

      final idUser = userData['id_user'];

      await supabase.from('freelancer_profiles').upsert({
        'id_user': idUser,
        'nama': nameController.text.trim(),
        'professional_status': professionalStatusController.text.trim(),
        'about_me': aboutMeController.text.trim(),
        'skills': skills,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id_user');

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

  // DIUBAH: addCertificate sekarang menerima data lengkap
  void addCertificateData(Map<String, dynamic> certData, VoidCallback refresh) {
    certificateData.add(certData);
    certificates.add(certData['file_url'] as String);
    refresh();
  }

  // DIUBAH: removeCertificate menggunakan index dari certificateData
  void removeCertificateData(int index, VoidCallback refresh) {
    if (index < certificateData.length) {
      certificateData.removeAt(index);
      certificates.removeAt(index);
    }
    refresh();
  }

  // Keep backward compat
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
