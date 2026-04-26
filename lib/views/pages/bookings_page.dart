import 'package:flutter/material.dart';
import '../../controllers/booking_controller.dart';
import '../../models/booking_model.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final controller = BookingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔥 SCALE SYSTEM
    double scale(double size) => size * (screenWidth / 375);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),

      body: SafeArea(
        child: Column(
          children: [

            // ================= HEADER =================
            Padding(
              padding: EdgeInsets.fromLTRB(
                scale(20),
                scale(16),
                scale(20),
                scale(4),
              ),
              child: Text(
                "My Bookings",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: scale(20), // 🔥 sedikit diperkecil biar proporsional
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ================= FILTER =================
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: scale(16),
                vertical: scale(6),
              ),
              child: Row(
                children: [
                  _filter("All", scale),
                  SizedBox(width: scale(8)),
                  _filter("Active", scale),
                  SizedBox(width: scale(8)),
                  _filter("Done", scale),
                ],
              ),
            ),

            SizedBox(height: scale(6)), // 🔥 spacing kecil biar lebih lega

            // ================= LIST =================
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  scale(16),
                  scale(4),
                  scale(16),
                  scale(16),
                ),
                itemCount: controller.filteredBookings.length,
                itemBuilder: (context, index) {
                  return _bookingCard(
                    controller.filteredBookings[index],
                    scale,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FILTER BUTTON =================
  Widget _filter(String text, double Function(double) scale) {
    final isActive = controller.selectedFilter == text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            controller.setFilter(text);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: scale(9)),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFA726) : Colors.white,
            borderRadius: BorderRadius.circular(scale(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: scale(5),
              )
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: scale(12),
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // ================= BOOKING CARD =================
  Widget _bookingCard(Booking b, double Function(double) scale) {
    return Container(
      margin: EdgeInsets.only(bottom: scale(12)),
      padding: EdgeInsets.all(scale(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: scale(8),
            offset: Offset(0, scale(3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= TOP =================
          Row(
            children: [

              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(scale(10)),
                child: Image.asset(
                  b.image,
                  width: scale(60),
                  height: scale(60),
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: scale(10)),

              // INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: scale(13),
                      ),
                    ),
                    Text(
                      b.providerName,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: scale(11),
                      ),
                    ),
                    SizedBox(height: scale(4)),
                    Text(
                      "Rp ${b.total}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: scale(12),
                      ),
                    ),
                  ],
                ),
              ),

              // STATUS
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: scale(8),
                  vertical: scale(5),
                ),
                decoration: BoxDecoration(
                  color: _statusColor(b.status),
                  borderRadius: BorderRadius.circular(scale(18)),
                ),
                child: Text(
                  b.status,
                  style: TextStyle(
                    fontSize: scale(10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: scale(12)),

          // ================= BOTTOM =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // ORDER DATE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Date",
                    style: TextStyle(
                      fontSize: scale(9),
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    b.orderDate,
                    style: TextStyle(fontSize: scale(11)),
                  ),
                ],
              ),

              // DEADLINE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Deadline",
                    style: TextStyle(
                      fontSize: scale(9),
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    b.deadline,
                    style: TextStyle(fontSize: scale(11)),
                  ),
                ],
              ),

              // BUTTON
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scale(12),
                    vertical: scale(7),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726),
                    borderRadius: BorderRadius.circular(scale(18)),
                  ),
                  child: Text(
                    "Details",
                    style: TextStyle(
                      fontSize: scale(11),
                      fontWeight: FontWeight.bold,
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

  // ================= STATUS COLOR =================
  Color _statusColor(String status) {
    switch (status) {
      case "Done":
        return Colors.green.withOpacity(0.2);
      case "In Progress":
        return Colors.blue.withOpacity(0.2);
      case "Pending":
        return Colors.orange.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}