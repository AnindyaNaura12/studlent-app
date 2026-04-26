import 'package:flutter/material.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Scale dengan clamp agar tidak overflow di layar kecil/besar
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8EE),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: s(18),
          ),
        ),
      ),

      body: SingleChildScrollView(
        // Mencegah garis hitam / glow effect di Android
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: s(20)),

            // ================= FOTO =================
            CircleAvatar(
              radius: s(45),
              backgroundColor: Colors.grey[300],
              backgroundImage: const AssetImage(
                'assets/images/icons/profile.png',
              ),
              onBackgroundImageError: (_, __) {},
              child: Icon(Icons.person, size: s(45), color: Colors.grey[600]),
            ),

            SizedBox(height: s(16)),

            // ================= NAMA =================
            Text(
              'Nama User / Klien',
              style: TextStyle(
                fontSize: s(18),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: s(4)),

            // ================= EMAIL =================
            Text(
              'user.client@example.com',
              style: TextStyle(color: Colors.grey, fontSize: s(13)),
            ),

            SizedBox(height: s(20)),

            // ================= EDIT BUTTON =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s(20)),
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, s(44)),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s(10)),
                  ),
                ),
                child: Text(
                  'Edit Profil',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: s(14),
                  ),
                ),
              ),
            ),

            SizedBox(height: s(20)),

            // ================= UPGRADE BANNER =================
            Container(
              margin: EdgeInsets.symmetric(horizontal: s(20), vertical: s(10)),
              padding: EdgeInsets.all(s(16)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(s(12)),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    color: Colors.blue,
                    size: s(30),
                  ),

                  SizedBox(width: s(12)),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Punya Keahlian?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: s(14),
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: s(4)),
                        Text(
                          'Daftar jadi freelancer dan mulai hasilkan uang tambahan!',
                          style: TextStyle(
                            fontSize: s(11),
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: s(8)),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: s(14),
                        vertical: s(8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(s(8)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Daftar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: s(12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: s(10)),

            // ================= MENU =================
            _buildMenuTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Pesanan Saya',
              s: s,
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.favorite_border_rounded,
              title: 'Freelancer Tersimpan',
              s: s,
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.settings_outlined,
              title: 'Pengaturan Akun',
              s: s,
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Pusat Bantuan',
              s: s,
              onTap: () {},
            ),

            SizedBox(height: s(20)),

            // ================= LOGOUT =================
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: s(20)),
              leading: Container(
                padding: EdgeInsets.all(s(8)),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(s(8)),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: s(20),
                ),
              ),
              title: Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: s(14),
                ),
              ),
              onTap: () {},
            ),

            SizedBox(height: s(30)),
          ],
        ),
      ),
    );
  }

  // ================= MENU TILE =================
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required double Function(double) s,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: s(20),
            vertical: s(2),
          ),
          leading: Container(
            padding: EdgeInsets.all(s(8)),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(s(8)),
            ),
            child: Icon(icon, size: s(20), color: Colors.black87),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: s(14),
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: s(14),
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        Divider(
          height: 1,
          indent: s(70),
          endIndent: s(20),
          color: Colors.black12,
        ),
      ],
    );
  }
}
