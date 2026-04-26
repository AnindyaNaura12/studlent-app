import 'package:flutter/material.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM
    double scale(double size) => size * (screenWidth / 375);

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
            fontSize: scale(18),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: scale(20)),

            // ================= FOTO =================
            CircleAvatar(
              radius: scale(45),
              backgroundImage:
                  const AssetImage('assets/images/icons/profile.png'),
              backgroundColor: Colors.grey,
            ),

            SizedBox(height: scale(16)),

            Text(
              'Nama User / Klien',
              style: TextStyle(
                fontSize: scale(18),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: scale(4)),

            Text(
              'user.client@example.com',
              style: TextStyle(
                color: Colors.grey,
                fontSize: scale(13),
              ),
            ),

            SizedBox(height: scale(20)),

            // ================= EDIT BUTTON =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: scale(20)),
              child: OutlinedButton(
                onPressed: () {},
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

            // ================= UPGRADE =================
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
                          'Daftar jadi freelancer dan mulai hasilkan uang tambahan!',
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

            // ================= MENU =================
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

            // ================= LOGOUT =================
            ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: scale(20)),
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
              onTap: () {},
            ),

            SizedBox(height: scale(30)),
          ],
        ),
      ),
    );
  }

  // ================= MENU TILE =================
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
            child: Icon(
              icon,
              size: scale(20),
              color: Colors.black87,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: scale(14),
            ),
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