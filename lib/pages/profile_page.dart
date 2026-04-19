import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isFreelancer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),

            // 🔵 HEADER
            _buildHeader(),

            const SizedBox(height: 20),

            // 🔵 TOGGLE ROLE
            _buildToggleRole(),

            const SizedBox(height: 25),

            // 🔵 STATS
            _buildStatsSection(),

            const SizedBox(height: 20),

            // 🔵 MENU
            _buildMenuList(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ======================
  // 🔵 HEADER
  // ======================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 16, color: Colors.black),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB74D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // 🔥 AVATAR (lebih menarik)
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orange.withOpacity(0.2),
            child: const CircleAvatar(
              radius: 46,
              backgroundImage:
                  AssetImage('assets/images/profile_user.png'),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Sarah Angel",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const Text(
            "UI/UX Design",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const Text(
            "Student of Universitas Brawijaya",
            style: TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 6),

          // 🔥 ROLE BADGE
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isFreelancer ? "Freelancer" : "Client",
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ======================
  // 🔵 TOGGLE ROLE
  // ======================
  Widget _buildToggleRole() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roleButton("Client", !isFreelancer),
          _roleButton("Freelancer", isFreelancer),
        ],
      ),
    );
  }

  Widget _roleButton(String text, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFreelancer = text == "Freelancer";
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFB74D) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ======================
  // 🔵 STATS
  // ======================
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("5", "Services"),
          _statItem("⭐ 4.8", "Rating"),
          _statItem("Rp 2jt", "Earned"),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style:
              const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // ======================
  // 🔵 MENU
  // ======================
  Widget _buildMenuList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _menuItem("My Skills", hasTag: true),
          _menuItem("My Portfolio"),
          _menuItem("Create Service"),
          _menuItem("Privacy Policy"),
          _menuItem("Logout"),
        ],
      ),
    );
  }

  Widget _menuItem(String title, {bool hasTag = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}