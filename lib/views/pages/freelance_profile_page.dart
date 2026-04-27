// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../controllers/profile_controller.dart';
import 'register_freelancer_page.dart'; // ← tambahan import

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = _controller.getClientUser();
    _nameController = TextEditingController(text: user.name);
    _usernameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: _controller.isFreelancer
          ? _buildFreelancerProfile()
          : _buildClientProfile(),
    );
  }

  // ─────────────────────────────────────────────
  // CLIENT PROFILE
  // ─────────────────────────────────────────────
  Widget _buildClientProfile() {
    final user = _controller.getClientUser();

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── HEADER ──
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0)],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 55),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showJoinFreelanceDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB74D),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Join Freelance",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFFFB74D), width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundImage: AssetImage(user.avatarPath),
                      onBackgroundImageError: (_, __) {},
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  user.location,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                _buildToggle(),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── STATS ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EBE0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(child: _statItem("${user.myOrders}", "My Orders")),
                  _verticalDivider(),
                  Expanded(child: _statItem(user.totalSpent, "Total Spent")),
                  _verticalDivider(),
                  Expanded(
                      child: _statItem(
                          "${user.completedOrders}", "Completed Orders")),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── EDITABLE FIELDS ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _editableField(
                  label: "Name",
                  displayText: _nameController.text.isNotEmpty
                      ? _nameController.text
                      : user.name,
                  controller: _nameController,
                ),
                const SizedBox(height: 12),
                _editableField(
                  label: "Username",
                  displayText: _usernameController.text.isNotEmpty
                      ? _usernameController.text
                      : user.username,
                  controller: _usernameController,
                ),
                const SizedBox(height: 12),
                _editableField(
                  label: "Email",
                  displayText: _emailController.text.isNotEmpty
                      ? _emailController.text
                      : user.email,
                  controller: _emailController,
                ),
                const SizedBox(height: 12),
                _passwordField(),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── BOTTOM MENU ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: _controller
                  .getClientMenuItems()
                  .map((item) => _menuItem(item['title'] as String))
                  .toList(),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FREELANCER PROFILE
  // ─────────────────────────────────────────────
  Widget _buildFreelancerProfile() {
    final user = _controller.getFreelancerUser();
    final menuItems = _controller.getFreelancerMenuItems();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit,
                          size: 16, color: Colors.black),
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
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundImage: AssetImage(user.avatarPath),
                    onBackgroundImageError: (_, __) {},
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.specialty,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  "Student of ${user.university}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Freelancer",
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildToggle(),
          const SizedBox(height: 25),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem("${user.services}", "Services"),
                _statItem("⭐ ${user.rating}", "Rating"),
                _statItem(user.earned, "Earned"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: menuItems
                  .map((item) => _menuItem(
                        item['title'] as String,
                        hasTag: item['hasTag'] as bool,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0D4),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roleButton("Client", !_controller.isFreelancer),
          _roleButton("Freelance", _controller.isFreelancer),
        ],
      ),
    );
  }

  Widget _roleButton(String text, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.isFreelancer = text == "Freelance";
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
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
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _editableField({
    required String label,
    required String displayText,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  style: const TextStyle(fontSize: 14, color: Colors.black45),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showEditDialog(context, label, controller),
            child: const Icon(Icons.edit_outlined,
                size: 20, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "••••••••••••••••••",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _menuItem(String title, {bool hasTag = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _controller.onMenuTap(title, context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const Text(
              ">",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DIALOGS
  // ─────────────────────────────────────────────

  void _showEditDialog(
      BuildContext context, String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter new $label",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB74D),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text("Save",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showJoinFreelanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.star, color: Color(0xFFFFB74D)),
            SizedBox(width: 8),
            Text("Join as Freelancer"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bergabung sebagai freelancer dan mulai tawarkan jasamu ke sesama mahasiswa!",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 16),
            Text("✅  Buat profil freelancer",
                style: TextStyle(fontSize: 13)),
            SizedBox(height: 6),
            Text("✅  Tawarkan skill & layananmu",
                style: TextStyle(fontSize: 13)),
            SizedBox(height: 6),
            Text("✅  Dapatkan penghasilan tambahan",
                style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Nanti Dulu"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB74D),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            // ── INI YANG DIUBAH ──
            onPressed: () {
              Navigator.pop(ctx); // tutup dialog dulu
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterFreelancerPage(),
                ),
              );
            },
            child: const Text(
              "Daftar Sekarang",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}