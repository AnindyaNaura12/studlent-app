import 'package:flutter/material.dart';
import '../../models/booking_model.dart';

class BookingDetailPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8EE),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Booking Detail",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(s(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER CARD =================
            Container(
              padding: EdgeInsets.all(s(14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(s(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: s(10),
                    offset: Offset(0, s(4)),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(s(12)),
                    child: Image.asset(
                      booking.image,
                      width: s(70),
                      height: s(70),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: s(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceName,
                          style: TextStyle(
                            fontSize: s(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: s(4)),
                        Text(
                          booking.providerName,
                          style: TextStyle(
                            fontSize: s(12),
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: s(6)),
                        Text(
                          "Rp ${booking.total}",
                          style: TextStyle(
                            fontSize: s(13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(booking.status, s),
                ],
              ),
            ),

            SizedBox(height: s(18)),

            // ================= DETAIL CARD =================
            Container(
              padding: EdgeInsets.all(s(14)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(s(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: s(10),
                    offset: Offset(0, s(4)),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _item("Order Date", booking.orderDate, s),
                  _divider(s),
                  _item("Deadline", booking.deadline, s),
                  _divider(s),
                  _columnNote("Note", booking.note, s),
                ],
              ),
            ),

            SizedBox(height: s(24)),

            // ================= ACTION BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  padding: EdgeInsets.symmetric(vertical: s(14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s(25)),
                  ),
                ),
                child: Text(
                  "Contact Freelancer",
                  style: TextStyle(
                    fontSize: s(13),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= ITEM =================
  Widget _item(String title, String value, double Function(double) s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: s(12),
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: s(12),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(double Function(double) s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(6)),
      child: Divider(
        thickness: 0.6,
        color: Colors.grey.withOpacity(0.3),
      ),
    );
  }


  Widget _columnNote(String title, String value, double Function(double) s) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: s(6)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: s(12),
            color: Colors.grey,
          ),
        ),
        SizedBox(height: s(4)),
        Text(
          value,
          style: TextStyle(
            fontSize: s(12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
  // ================= STATUS BADGE =================
  Widget _statusBadge(String status, double Function(double) s) {
    Color bg;
    Color text;

    switch (status) {
      case "Done":
        bg = Colors.green.withOpacity(0.15);
        text = Colors.green[700]!;
        break;
      case "In Progress":
        bg = Colors.blue.withOpacity(0.15);
        text = Colors.blue[700]!;
        break;
      case "Pending":
        bg = Colors.orange.withOpacity(0.15);
        text = Colors.orange[800]!;
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        text = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(10), vertical: s(6)),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(s(20)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: s(10),
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}