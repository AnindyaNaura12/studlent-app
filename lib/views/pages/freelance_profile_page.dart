// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/profile_controller.dart';
import 'register_freelancer_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'edit_client_profile_page.dart';
import 'my_profile_page.dart';
import '../../main.dart';
import 'chat_list_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();
  bool _loading = true;
  Map<String, dynamic>? _userData;
  StreamSubscription? _authSubscription;

  String _earnedPeriod = 'monthly';
  Map<String, dynamic> _freelancerStats = {
    'services': 0,
    'rating': 0.0,
    'earned': 0.0,
  };

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  String _formatRupiah(double amount) {
    final n = amount.toInt();
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _fetchUserData();

    _authSubscription = _controller.supabase.auth.onAuthStateChange.listen((
      data,
    ) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        if (!mounted) return;
        setState(() => _loading = true);
        _fetchUserData();
      } else if (event == AuthChangeEvent.signedOut) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        setState(() {
          _controller.isLoggedIn = false;
          _userData = null;
          _loading = false;
        });
      }
    });
  }

  void _fetchUserData() async {
    final session = _controller.supabase.auth.currentSession;
    if (session == null) {
      if (!mounted) return;
      setState(() {
        _controller.isLoggedIn = false;
        _loading = false;
      });
      return;
    }

    final data = await _controller.getCurrentUser();

    if (!mounted) return;

    if (data != null) {
      setState(() {
        _userData = data;
        _controller.isLoggedIn = true;
        _controller.isFreelancer = data['role'] == 'freelancer';
        _nameController.text = data['nama'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
        _loading = false;
        globalUsername.value = data['username'] ?? ''; // ← TAMBAH
      });

      if (data['role'] == 'freelancer') {
        final stats = await _controller.getFreelancerStats(
          data['id_user'],
          'monthly',
        );
        if (!mounted) return;
        setState(() => _freelancerStats = stats);
      }
    } else {
      if (!mounted) return;
      setState(() {
        _controller.isLoggedIn = false;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8EE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_controller.isLoggedIn) {
      return _buildGuestProfile();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: _controller.isFreelancer
          ? _buildFreelancerProfile()
          : _buildClientProfile(),
    );
  }

  // ─────────────────────────────────────────────
  // GUEST PROFILE
  // ─────────────────────────────────────────────
  Widget _buildGuestProfile() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD59E), Colors.white],
            stops: [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  child: const Icon(Icons.person, size: 44, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Welcome to Studlent!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Login or register as a client\nto get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE8D8C0),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "You're not logged in yet",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please login or register\nto get started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB74D),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB74D),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CLIENT PROFILE
  // ─────────────────────────────────────────────
  Widget _buildClientProfile() {
    return SingleChildScrollView(
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _showJoinFreelanceDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
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
          GestureDetector(
            onTap: () async {
              if (_userData == null) return;
              final url = await _controller.uploadProfileImage(
                _userData!['id_user'],
                isFreelancer: false,
              );
              if (!mounted) return;
              if (url != null) setState(() => _userData!['foto'] = url);
            },
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFFB74D),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    child: ClipOval(
                      child: _userData?['foto'] != null
                          ? Image.network(
                              _userData!['foto'],
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              key: ValueKey(_userData!['foto']),
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/images/icons/profile.png',
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/images/icons/profile.png',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB74D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _nameController.text.isNotEmpty
                ? _nameController.text
                : 'Nama User',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text.isNotEmpty
                ? _emailController.text
                : 'email@example.com',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          _buildToggle(),
          const SizedBox(height: 24),
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
                  Expanded(
                    child: _statItem(
                      '${_userData?['my_orders'] ?? 0}',
                      'My Orders',
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _statItem(
                      'Rp ${_formatRupiah((_userData?['total_spent'] ?? 0).toDouble())}',
                      'Total Spent',
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _statItem(
                      '${_userData?['completed_orders'] ?? 0}',
                      'Completed Orders',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _editableField(
                  label: "Name",
                  displayText: _nameController.text,
                  controller: _nameController,
                ),
                const SizedBox(height: 12),
                _editableField(
                  label: "Username",
                  displayText: _usernameController.text,
                  controller: _usernameController,
                ),
                const SizedBox(height: 12),
                _editableField(
                  label: "Email",
                  displayText: _emailController.text,
                  controller: _emailController,
                ),
                const SizedBox(height: 12),
                _passwordField(),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
    final menuItems = _controller.getFreelancerMenuItems();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Row(
                  children: [
                    Text(
                      "My Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: ClipOval(
                    child: _userData?['foto_freelancer'] != null
                        ? Image.network(
                            _userData!['foto_freelancer'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            key: ValueKey(_userData!['foto_freelancer']),
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/icons/profile.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/icons/profile.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _userData?['nama'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _userData?['professional_status'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Freelancer",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('${_freelancerStats['services']}', 'Services'),
                _verticalDivider(),
                _statItem('⭐ ${_freelancerStats['rating']}', 'Rating'),
                _verticalDivider(),
                Column(
                  children: [
                    Text(
                      'Rp ${_formatRupiah((_freelancerStats['earned'] ?? 0).toDouble())}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showEarnedFilterSheet(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _earnedPeriod == 'weekly'
                                ? 'Mingguan'
                                : _earnedPeriod == 'yearly'
                                ? 'Tahunan'
                                : 'Bulanan',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: menuItems.map((item) {
                final title = item['title'] as String;
                final hasTag = item['hasTag'] as bool;

                if (title == 'My Profile') {
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileFreelancerPage(),
                        ),
                      );
                      if (!mounted) return;
                      _fetchUserData();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
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
                            child: Text(
                              'My Profile',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            ">",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return _menuItem(title, hasTag: hasTag, onTap: () {
                  if (title == 'Chat') {
                    // Berpindah ke ChatListPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatListPage(isFreelancerMode: true),
                      ),
                    );
                  } else {
                    _controller.onMenuTap(title, context);
                  }
                });
              }).toList(),
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
      onTap: () async {
        if (text == "Freelance") {
          final isRegistered = _userData?['role'] == 'freelancer';
          if (!isRegistered) {
            _showJoinFreelanceDialog(context);
            return;
          }
        }
        setState(() => _controller.isFreelancer = text == "Freelance");
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFB74D) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
    return Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3));
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
            child: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: Colors.black54,
            ),
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

  Widget _menuItem(String title, {bool hasTag = false, VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ?? () => _controller.onMenuTap(title, context), 
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DIALOGS & SHEETS
  // ─────────────────────────────────────────────
  void _showEarnedFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filter Penghasilan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            for (final option in [
              {'label': 'Mingguan', 'value': 'weekly'},
              {'label': 'Bulanan', 'value': 'monthly'},
              {'label': 'Tahunan', 'value': 'yearly'},
            ])
              ListTile(
                title: Text(option['label']!),
                trailing: _earnedPeriod == option['value']
                    ? const Icon(Icons.check, color: Color(0xFFFFB74D))
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  setState(() => _earnedPeriod = option['value']!);
                  if (_userData != null) {
                    final stats = await _controller.getFreelancerStats(
                      _userData!['id_user'],
                      option['value']!,
                    );
                    if (!mounted) return;
                    setState(() => _freelancerStats = stats);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter new $label",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              if (_userData == null) return;
              await _controller.updateProfile(
                idUser: _userData!['id_user'],
                nama: _nameController.text.trim(),
                username: _usernameController.text.trim(),
                noHp: _userData!['no_hp'] ?? '',
              );
              if (!mounted) return;
              globalUsername.value = _usernameController.text
                  .trim(); // ← TAMBAH
              setState(() {});
            },
            child: const Text("Save", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showJoinFreelanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            Text("✅  Buat profil freelancer", style: TextStyle(fontSize: 13)),
            SizedBox(height: 6),
            Text(
              "✅  Tawarkan skill & layananmu",
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              "✅  Dapatkan penghasilan tambahan",
              style: TextStyle(fontSize: 13),
            ),
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
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
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
