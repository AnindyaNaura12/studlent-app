import 'package:flutter/material.dart';
import 'home_content.dart';
import 'profile_page.dart';
import 'bookings_page.dart'; 
import 'services_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const ServicesPage(),
    const Center(child: Text("Chat")),
    const BookingsPage(), // Menggunakan BookingsPage yang sudah dibuat
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
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
            _buildNavItem("assets/images/icons/bookings.png", "Bookings"),
            _buildNavItem("assets/images/icons/profile.png", "Profile"),
          ],
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
