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

  List<Map<String, dynamic>> certificates = [];

  EditProfileController({FreelancerProfileModel? initialModel})
      : model = initialModel ?? FreelancerProfileModel() {
    nameController = TextEditingController(text: model.name);
    professionalStatusController =
        TextEditingController(text: model.professionalStatus);
    aboutMeController = TextEditingController(text: model.aboutMe);
    skillInputController = TextEditingController();
    skills = List<String>.from(model.skills);
  }

  // ── Load dari Supabase ────────────────────────────────────
  Future<void> loadFromSupabase() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        debugPrint('[EditProfileController] loadFromSupabase: user belum login');
        return;
      }

      // 1. Ambil data user
      final user = await supabase
          .from('users')
          .select('id_user, nama')
          .eq('email', authUser.email!)
          .single();

      final idUser = user['id_user'] as int;
      nameController.text = user['nama'] ?? '';

      // 2. Ambil freelancer_profiles
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

      // 3. Ambil skills
      final skillsResult = await supabase
          .from('freelancer_skills')
          .select('skill_name')
          .eq('id_user', idUser);

      skills = (skillsResult as List)
          .map((s) => s['skill_name'] as String)
          .toList();

      // 4. Ambil sertifikat yang sudah ada di DB
      final certsResult = await supabase
          .from('freelancer_certificates')
          .select('id_certificate, file_url, file_name')
          .eq('id_user', idUser)
          .order('created_at');

      certificates = (certsResult as List).map((c) {
        return {
          'id_certificate': c['id_certificate'],
          'file_url': c['file_url'] ?? '',
          'file_name': c['file_name'] ?? '',
          'is_existing': true,
        };
      }).toList();

      debugPrint('[EditProfileController] Load berhasil: '
          '${skills.length} skills, ${certificates.length} sertifikat');
    } on PostgrestException catch (e) {
      debugPrint('[EditProfileController] loadFromSupabase PostgrestException: '
          'code=${e.code} | message=${e.message} | hint=${e.hint}');
      debugPrint('  → Kemungkinan RLS memblokir SELECT. '
          'Pastikan policy SELECT sudah aktif untuk tabel terkait.');
    } catch (e, stack) {
      debugPrint('[EditProfileController] loadFromSupabase error: $e');
      debugPrint(stack.toString());
    }
  }

  // ── Save ke Supabase ──────────────────────────────────────
  Future<bool> saveToSupabase() async {
    try {
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        debugPrint('[EditProfileController] saveToSupabase: user belum login');
        return false;
      }

      final user = await supabase
          .from('users')
          .select('id_user')
          .eq('email', authUser.email!)
          .single();

      final idUser = user['id_user'] as int;
      final now = DateTime.now().toIso8601String();

      // ── STEP 1: Update tabel users (hanya kolom yang ada) ──
      await supabase.from('users').update({
        'nama': nameController.text.trim(),
        'updated_at': now,
      }).eq('id_user', idUser);

      debugPrint('[EditProfileController] Step 1 ✓ users updated');

      // ── STEP 2: Upsert freelancer_profiles ──
      await supabase.from('freelancer_profiles').upsert(
        {
          'id_user': idUser,
          'professional_status': professionalStatusController.text.trim(),
          'bio': aboutMeController.text.trim(),
          'updated_at': now,
        },
        onConflict: 'id_user',
      );

      debugPrint('[EditProfileController] Step 2 ✓ freelancer_profiles upserted');

      // ── STEP 3: Sync skills (delete lama → insert baru) ──
      await supabase
          .from('freelancer_skills')
          .delete()
          .eq('id_user', idUser);

      if (skills.isNotEmpty) {
        final skillRows = skills.map((skill) => {
          'id_user': idUser,
          'skill_name': skill.trim(),
          'created_at': now,
          'updated_at': now,
        }).toList();

        await supabase.from('freelancer_skills').insert(skillRows);
      }

      debugPrint('[EditProfileController] Step 3 ✓ '
          '${skills.length} skills synced');

      // ── STEP 4: Simpan sertifikat baru ──
      final newCerts = certificates
          .where((c) => c['is_existing'] != true)
          .toList();

      if (newCerts.isNotEmpty) {
        final certRows = newCerts.map((c) => {
          'id_user': idUser,
          'file_url': c['file_url'] ?? '',
          'file_name': c['file_name'] ?? '',
          'created_at': now,
          'updated_at': now,
        }).toList();

        await supabase.from('freelancer_certificates').insert(certRows);
        debugPrint('[EditProfileController] Step 4 ✓ '
            '${newCerts.length} sertifikat baru disimpan');
      } else {
        debugPrint('[EditProfileController] Step 4 ✓ '
            'Tidak ada sertifikat baru untuk disimpan');
      }

      return true;
    } on PostgrestException catch (e) {
      // Error spesifik dari Supabase/PostgREST
      debugPrint('══════════════════════════════════════════');
      debugPrint('[EditProfileController] ⛔ SUPABASE ERROR saat save:');
      debugPrint('  code    : ${e.code}');
      debugPrint('  message : ${e.message}');
      debugPrint('  hint    : ${e.hint}');
      debugPrint('  details : ${e.details}');
      if (e.code == '42501' || (e.message?.contains('policy') ?? false)) {
        debugPrint('  → ⚠️  KEMUNGKINAN MASALAH RLS (Row Level Security)!');
        debugPrint('  → Cek Supabase Dashboard > Authentication > Policies');
        debugPrint('  → Pastikan policy UPDATE/INSERT/DELETE sudah aktif');
        debugPrint('  → untuk tabel: users, freelancer_profiles,');
        debugPrint('     freelancer_skills, freelancer_certificates');
      }
      debugPrint('══════════════════════════════════════════');
      return false;
    } catch (e, stack) {
      debugPrint('[EditProfileController] ⛔ saveToSupabase unexpected error: $e');
      debugPrint(stack.toString());
      return false;
    }
  }

  // ── Skill helpers ─────────────────────────────────────────
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

  // ── Certificate helpers ───────────────────────────────────
  void addCertificate({
    required String fileUrl,
    required String fileName,
    required VoidCallback refresh,
  }) {
    certificates.add({
      'file_url': fileUrl,
      'file_name': fileName,
      'is_existing': false,
    });
    refresh();
  }

  Future<void> removeCertificate(int index, VoidCallback refresh) async {
    final cert = certificates[index];

    if (cert['is_existing'] == true && cert['id_certificate'] != null) {
      try {
        await supabase
            .from('freelancer_certificates')
            .delete()
            .eq('id_certificate', cert['id_certificate']);
        debugPrint('[EditProfileController] Sertifikat id=${cert['id_certificate']} dihapus dari DB');
      } on PostgrestException catch (e) {
        debugPrint('[EditProfileController] ⛔ Gagal hapus sertifikat dari DB: '
            'code=${e.code} | ${e.message}');
        if (e.code == '42501') {
          debugPrint('  → ⚠️  RLS memblokir DELETE di freelancer_certificates');
        }
      } catch (e) {
        debugPrint('[EditProfileController] ⛔ removeCertificate error: $e');
      }
    }

    certificates.removeAt(index);
    refresh();
  }

  // ── Validation ────────────────────────────────────────────
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