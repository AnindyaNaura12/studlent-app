import '../models/booking_model.dart';

class BookingController {
  String selectedFilter = 'All';

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
  ];

  List<Booking> get filteredBookings {
    if (selectedFilter == 'Active') {
      return bookings.where((b) => b.status == 'In Progress').toList();
    }
    if (selectedFilter == 'Done') {
      return bookings.where((b) => b.status == 'Done').toList();
    }
    return bookings;
  }

  void setFilter(String filter) {
    selectedFilter = filter;
  }
}