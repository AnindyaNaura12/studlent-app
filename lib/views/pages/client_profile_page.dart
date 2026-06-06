import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import 'edit_client_profile_page.dart';
import 'login_page.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final ProfileController _controller = ProfileController();
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _loading = true);
    final data = await _controller.getCurrentUser();
    setState(() {
      _userData = data;
      _loading = false;
    });
  }

  String _formatRupiah(double amount) {
    final n = amount.toInt();
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double scale(double size) => size * (screenWidth / 375);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8EE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: scale(40)),

            // ── Foto Profil (bisa diklik) ──────────────────
            GestureDetector(
              onTap: () async {
                if (_userData == null) return;
                final url = await _controller.uploadProfileImage(
                  _userData!['id_user'],
                );
                if (url != null) {
                  setState(() => _userData!['foto'] = url);
                }
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: scale(45),
                    backgroundImage: _userData?['foto'] != null
                        ? NetworkImage(_userData!['foto']) as ImageProvider
                        : const AssetImage('assets/images/icons/profile.png'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(scale(6)),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: scale(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: scale(12)),

            // ── Nama ──────────────────────────────────────
            Text(
              _userData?['nama'] ?? 'Nama User',
              style: TextStyle(
                fontSize: scale(18),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: scale(4)),

            // ── Email ─────────────────────────────────────
            Text(
              _userData?['email'] ?? 'email@example.com',
              style: TextStyle(color: Colors.grey, fontSize: scale(13)),
            ),

            SizedBox(height: scale(20)),

            // ── Statistik ─────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scale(20)),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: scale(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(scale(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      title: 'My Orders',
                      value: '${_userData?['my_orders'] ?? 0}',
                      scale: scale,
                    ),
                    Container(
                      width: 1,
                      height: scale(40),
                      color: Colors.black12,
                    ),
                    _buildStatItem(
                      title: 'Total Spent',
                      value:
                          'Rp ${_formatRupiah((_userData?['total_spent'] ?? 0).toDouble())}',
                      scale: scale,
                    ),
                    Container(
                      width: 1,
                      height: scale(40),
                      color: Colors.black12,
                    ),
                    _buildStatItem(
                      title: 'Completed',
                      value: '${_userData?['completed_orders'] ?? 0}',
                      scale: scale,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: scale(20)),

            // ── Tombol Edit Profil ────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scale(20)),
              child: OutlinedButton(
                onPressed: () async {
                  if (_userData == null) return;
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditClientProfilePage(userData: _userData!),
                    ),
                  );
                  if (updated == true) _fetchUserData();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, scale(44)),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(scale(10)),
                  ),
                ),
                child: Text(
                  'Edit Profil',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: scale(14),
                  ),
                ),
              ),
            ),

            SizedBox(height: scale(20)),

            // ── Banner Upgrade Freelancer ─────────────────
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: scale(20),
                vertical: scale(10),
              ),
              padding: EdgeInsets.all(scale(16)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(scale(12)),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    color: Colors.blue,
                    size: scale(30),
                  ),
                  SizedBox(width: scale(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Punya Keahlian?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: scale(14),
                          ),
                        ),
                        SizedBox(height: scale(4)),
                        Text(
                          'Daftar jadi freelancer dan mulai hasilkan uang!',
                          style: TextStyle(
                            fontSize: scale(11),
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: scale(8)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: scale(14),
                        vertical: scale(8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(scale(8)),
                      ),
                    ),
                    child: Text(
                      'Daftar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scale(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: scale(10)),

            // ── Menu ──────────────────────────────────────
            _buildMenuTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Pesanan Saya',
              scale: scale,
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.favorite_border_rounded,
              title: 'Freelancer Tersimpan',
              scale: scale,
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.settings_outlined,
              title: 'Pengaturan Akun',
              scale: scale,
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Pusat Bantuan',
              scale: scale,
              onTap: () {},
            ),

            SizedBox(height: scale(20)),

            // ── Logout ────────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: scale(20)),
              leading: Container(
                padding: EdgeInsets.all(scale(8)),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(scale(8)),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: scale(20),
                ),
              ),
              title: Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: scale(14),
                ),
              ),
              onTap: () => _controller.logout(context),
            ),

            SizedBox(height: scale(30)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Function(double) scale,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: scale(16)),
        ),
        SizedBox(height: scale(4)),
        Text(
          title,
          style: TextStyle(color: Colors.grey, fontSize: scale(11)),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Function(double) scale,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: scale(20),
            vertical: scale(2),
          ),
          leading: Container(
            padding: EdgeInsets.all(scale(8)),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(scale(8)),
            ),
            child: Icon(icon, size: scale(20), color: Colors.black87),
          ),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: scale(14)),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: scale(14),
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        Divider(
          height: 1,
          indent: scale(70),
          endIndent: scale(20),
          color: Colors.black12,
        ),
      ],
    );
  }
}
