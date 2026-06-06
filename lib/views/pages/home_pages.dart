// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'home_content.dart';
import 'freelance_profile_page.dart';
import 'bookings_page.dart';
import 'services_page.dart';
import 'chat_list_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  String? _initialCategory;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _goToServicesWithCategory(String category) {
    setState(() {
      _initialCategory = category;
      _selectedIndex = 1;
    });
  }

  void _goToProfileTab() {
    setState(() {
      _selectedIndex = 4;
      _initialCategory = null;
    });
  }

  void _goToPageFromSearch(int index, {String? category}) {
    setState(() {
      _selectedIndex = index;
      _initialCategory = index == 1 ? category : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(
        onCategoryTap: _goToServicesWithCategory,
        onProfileTap: _goToProfileTab,
        onGlobalSearchNavigate: _goToPageFromSearch,
      ),
      ServicesPage(
        key: ValueKey(_initialCategory ?? 'all-services'),
        initialCategory: _initialCategory,
      ),
      const ChatListPage(),
      const BookingsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: const Color(0xFFFFA726).withOpacity(0.20),
          highlightColor: const Color(0xFFFFA726).withOpacity(0.10),
          splashFactory: InkRipple.splashFactory,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (index != 1) _initialCategory = null;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: [
              _buildNavItem("assets/images/icons/home.png", "Home"),
              _buildNavItem("assets/images/icons/services.png", "Services"),
              _buildNavItem("assets/images/icons/chat.png", "Chat"),
              _buildNavItem("assets/images/icons/bookings.png", "My Orders"),
              _buildNavItem("assets/images/icons/profile.png", "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: Image.asset(iconPath, width: 24, height: 24),
      label: label,
    );
  }
}
