// lib/views/pages/bookings_page.dart

import 'package:flutter/material.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String selectedFilter = 'All';

  List<Booking> get filteredBookings {
    if (selectedFilter == 'All') return bookings;
    if (selectedFilter == 'Active') {
      return bookings.where((b) => b.status == 'In Progress').toList();
    }
    if (selectedFilter == 'Done') {
      return bookings.where((b) => b.status == 'Done').toList();
    }
    return bookings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan gradient oranye ke putih
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFD9A0), Colors.white],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: const Center(
                child: Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Filter buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterButton('All'),
                  const SizedBox(width: 12),
                  _buildFilterButton('Active'),
                  const SizedBox(width: 12),
                  _buildFilterButton('Done'),
                ],
              ),
            ),

            // List of bookings
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  return _buildBookingItem(filteredBookings[index]);
                },
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
    );
  }

  Widget _buildFilterButton(String label) {
    final bool isSelected = selectedFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5A623),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingItem(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  booking.image,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Booking details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.providerName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'Total: '),
                          TextSpan(
                            text: 'Rp. ${booking.total}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking.status,
                        style: TextStyle(
                          color: booking.status == 'Pending'
                              ? Colors.black
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Order Date, Deadline, and View Details row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Date:',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(booking.orderDate, style: const TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deadline:',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(booking.deadline, style: const TextStyle(fontSize: 13)),
                ],
              ),
              const Spacer(),
              // View Details button
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5A623),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return const Color(0xFF7BB8F0); // biru muda
      case 'Done':
        return const Color(0xFF4CAF50); // hijau
      case 'Pending':
        return const Color(0xFFFFEB3B); // kuning
      default:
        return Colors.grey;
    }
  }
}

class Booking {
  final String serviceName;
  final String providerName;
  final String total;
  final String orderDate;
  final String deadline;
  final String status;
  final String image;

  Booking({
    required this.serviceName,
    required this.providerName,
    required this.total,
    required this.orderDate,
    required this.deadline,
    required this.status,
    required this.image,
  });
}

List<Booking> bookings = [
  Booking(
    serviceName: 'Website Development',
    providerName: 'Jessica Jung',
    total: '550.000',
    orderDate: '24 July, 2026',
    deadline: '12 October, 2026',
    status: 'In Progress',
    image: 'assets/images/freelancers/freelancer_1.png',
  ),
  Booking(
    serviceName: 'Write & Translation',
    providerName: 'Jisoo Park',
    total: '250.000',
    orderDate: '24 July, 2026',
    deadline: '12 October, 2026',
    status: 'Done',
    image: 'assets/images/freelancers/freelancer_2.png',
  ),
  Booking(
    serviceName: 'Write & Translation',
    providerName: 'Jisoo Park',
    total: '250.000',
    orderDate: '24 July, 2026',
    deadline: '12 October, 2026',
    status: 'Pending',
    image: 'assets/images/freelancers/freelancer_3.png',
  ),
];
