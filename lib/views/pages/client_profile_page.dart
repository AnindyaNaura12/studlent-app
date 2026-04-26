import 'package:flutter/material.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- BAGIAN FOTO & INFO USER ---
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/icons/profile.png'), // Sesuaikan path asset
              backgroundColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nama User / Klien',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'user.client@example.com',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // --- TOMBOL EDIT PROFIL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigasi ke halaman Edit Profil
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit Profil',
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- MENU UPGRADE KE FREELANCER (HIGHLIGHTED) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline_rounded, color: Colors.blue, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Punya Keahlian?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Daftar jadi freelancer dan mulai hasilkan uang tambahan!',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigasi ke Form Registrasi Freelancer
                      // Contoh: Navigator.pushNamed(context, '/register_freelancer');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Daftar', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- MENU LAINNYA ---
            _buildMenuTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Pesanan Saya',
              onTap: () {
                // Navigasi ke riwayat pesanan (bookings)
              },
            ),
            _buildMenuTile(
              icon: Icons.favorite_border_rounded,
              title: 'Freelancer Tersimpan',
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.settings_outlined,
              title: 'Pengaturan Akun',
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Pusat Bantuan',
              onTap: () {},
            ),
            
            const SizedBox(height: 20),
            
            // --- TOMBOL LOGOUT ---
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.red),
              ),
              title: const Text(
                'Keluar',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // TODO: Fungsi Logout dan hapus sesi
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat list menu agar kode lebih rapi
  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1, indent: 70, endIndent: 20, color: Colors.black12),
      ],
    );
  }
}