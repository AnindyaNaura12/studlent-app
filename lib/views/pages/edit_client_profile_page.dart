import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';

class EditClientProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditClientProfilePage({super.key, required this.userData});

  @override
  State<EditClientProfilePage> createState() =>
      _EditClientProfilePageState();
}

class _EditClientProfilePageState extends State<EditClientProfilePage> {
  final ProfileController _controller = ProfileController();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _noHpCtrl;
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();

  bool _loading = false;
  bool _showPassword = false;
  bool _showKonfirmasi = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl =
        TextEditingController(text: widget.userData['nama'] ?? '');
    _usernameCtrl =
        TextEditingController(text: widget.userData['username'] ?? '');
    _emailCtrl =
        TextEditingController(text: widget.userData['email'] ?? '');
    _noHpCtrl =
        TextEditingController(text: widget.userData['no_hp'] ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _noHpCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Update nama, username, no_hp
    final success = await _controller.updateProfile(
      idUser: widget.userData['id_user'],
      nama: _namaCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      noHp: _noHpCtrl.text.trim(),
    );

    // Update password kalau diisi
    if (_passwordCtrl.text.isNotEmpty) {
      await _controller.updatePassword(_passwordCtrl.text);
    }

    setState(() => _loading = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // trigger refresh di profile page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan, coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scale(double size) => size * (screenWidth / 375);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8EE),
        elevation: 0,
        title: Text(
          'Edit Profil',
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: scale(16)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: scale(20)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: scale(24)),

              _buildField(
                label: 'Nama Lengkap',
                controller: _namaCtrl,
                icon: Icons.person_outline_rounded,
                scale: scale,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              SizedBox(height: scale(16)),

              _buildField(
                label: 'Username',
                controller: _usernameCtrl,
                icon: Icons.alternate_email_rounded,
                scale: scale,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Username tidak boleh kosong' : null,
              ),
              SizedBox(height: scale(16)),

              // Email — tidak bisa diubah
              _buildField(
                label: 'Email',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                scale: scale,
                enabled: false,
                helperText: 'Email tidak dapat diubah',
              ),
              SizedBox(height: scale(16)),

              _buildField(
                label: 'No. HP',
                controller: _noHpCtrl,
                icon: Icons.phone_outlined,
                scale: scale,
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: scale(28)),
              Divider(color: Colors.black12),
              SizedBox(height: scale(12)),

              Text(
                'Ganti Password',
                style: TextStyle(
                    fontSize: scale(13),
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                'Kosongkan jika tidak ingin ganti password',
                style:
                    TextStyle(fontSize: scale(11), color: Colors.grey),
              ),
              SizedBox(height: scale(16)),

              _buildField(
                label: 'Password Baru',
                controller: _passwordCtrl,
                icon: Icons.lock_outline_rounded,
                scale: scale,
                obscure: !_showPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey,
                    size: scale(18),
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
                validator: (v) {
                  if (v!.isNotEmpty && v.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: scale(16)),

              _buildField(
                label: 'Konfirmasi Password',
                controller: _konfirmasiCtrl,
                icon: Icons.lock_outline_rounded,
                scale: scale,
                obscure: !_showKonfirmasi,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showKonfirmasi
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey,
                    size: scale(18),
                  ),
                  onPressed: () => setState(
                      () => _showKonfirmasi = !_showKonfirmasi),
                ),
                validator: (v) {
                  if (_passwordCtrl.text.isNotEmpty &&
                      v != _passwordCtrl.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),

              SizedBox(height: scale(36)),

              SizedBox(
                width: double.infinity,
                height: scale(48),
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(scale(12))),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: scale(15)),
                        ),
                ),
              ),

              SizedBox(height: scale(40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Function(double) scale,
    bool obscure = false,
    bool enabled = true,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: scale(14)),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon:
            Icon(icon, size: scale(20), color: Colors.blue),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
            enabled ? Colors.white : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scale(10)),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scale(10)),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scale(10)),
          borderSide:
              const BorderSide(color: Colors.blue, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(scale(10)),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: scale(12), vertical: scale(14)),
      ),
    );
  }
}