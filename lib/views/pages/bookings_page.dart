import 'package:flutter/material.dart';
import '../../controllers/booking_controller.dart';
import '../../models/booking_model.dart';
import 'booking_detail_page.dart';

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

    // Scale dengan clamp agar tidak overflow di layar kecil/besar
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: EdgeInsets.fromLTRB(s(20), s(16), s(20), s(4)),
              child: Text(
                "My Bookings",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: s(20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // ================= FILTER =================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(6)),
              child: Row(
                children: [
                  _filter("All", s),
                  SizedBox(width: s(8)),
                  _filter("Active", s),
                  SizedBox(width: s(8)),
                  _filter("Done", s),
                ],
              ),
            ),

            SizedBox(height: s(6)),

            // ================= LIST =================
            Expanded(
              child: ListView.builder(
                // Mencegah garis hitam / glow effect di Android
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(s(16), s(4), s(16), s(16)),
                itemCount: controller.filteredBookings.length,
                itemBuilder: (context, index) {
                  return _bookingCard(controller.filteredBookings[index], s);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FILTER BUTTON =================
  Widget _filter(String text, double Function(double) s) {
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
          padding: EdgeInsets.symmetric(vertical: s(9)),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFA726) : Colors.white,
            borderRadius: BorderRadius.circular(s(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: s(5),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: s(12),
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // ================= BOOKING CARD =================
  Widget _bookingCard(Booking b, double Function(double) s) {
    return Container(
      margin: EdgeInsets.only(bottom: s(12)),
      padding: EdgeInsets.all(s(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: s(8),
            offset: Offset(0, s(3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= TOP ROW =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(s(10)),
                child: Image.asset(
                  b.image,
                  width: s(60),
                  height: s(60),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: s(60),
                    height: s(60),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(s(10)),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: s(24),
                    ),
                  ),
                ),
              ),

              SizedBox(width: s(10)),

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
                        fontSize: s(13),
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      b.providerName,
                      style: TextStyle(color: Colors.grey, fontSize: s(11)),
                    ),
                    SizedBox(height: s(4)),
                    Text(
                      "Rp ${b.total}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: s(12),
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: s(6)),

              // STATUS
              Container(
                padding: EdgeInsets.symmetric(horizontal: s(8), vertical: s(5)),
                decoration: BoxDecoration(
                  color: _statusColor(b.status),
                  borderRadius: BorderRadius.circular(s(18)),
                ),
                child: Text(
                  b.status,
                  style: TextStyle(
                    fontSize: s(10),
                    fontWeight: FontWeight.bold,
                    color: _statusTextColor(b.status),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: s(12)),

          // ================= BOTTOM ROW =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ORDER DATE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Date",
                    style: TextStyle(fontSize: s(9), color: Colors.grey),
                  ),
                  Text(
                    b.orderDate,
                    style: TextStyle(fontSize: s(11), color: Colors.black87),
                  ),
                ],
              ),

              // DEADLINE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Deadline",
                    style: TextStyle(fontSize: s(9), color: Colors.grey),
                  ),
                  Text(
                    b.deadline,
                    style: TextStyle(fontSize: s(11), color: Colors.black87),
                  ),
                ],
              ),

              // DETAILS BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (_) => BookingDetailPage(booking: b)
                      ),
                    );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(12),
                    vertical: s(7),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726),
                    borderRadius: BorderRadius.circular(s(18)),
                  ),
                  child: Text(
                    "Details",
                    style: TextStyle(
                      fontSize: s(11),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
        return Colors.green.withOpacity(0.15);
      case "In Progress":
        return Colors.blue.withOpacity(0.15);
      case "Pending":
        return Colors.orange.withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }

  // ================= STATUS TEXT COLOR =================
  Color _statusTextColor(String status) {
    switch (status) {
      case "Done":
        return Colors.green[700]!;
      case "In Progress":
        return Colors.blue[700]!;
      case "Pending":
        return Colors.orange[800]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
