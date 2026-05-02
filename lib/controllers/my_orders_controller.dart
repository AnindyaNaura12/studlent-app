import 'package:flutter/material.dart';
import '../models/order_model.dart';

class MyOrdersController {
  final List<OrderModel> orders = [
    OrderModel(
      id: '1',
      freelancerName: 'Sarah Angel',
      freelancerAvatar: 'assets/images/freelancers/freelancer_1.png',
      serviceName: 'Figma UI/UX Design',
      price: 'Rp. 200.000',
      deadline: '26 October 2025',
      status: 'In Progress',
      note: 'Polish my history dissertation, what needs to each in every page',
    ),
    OrderModel(
      id: '2',
      freelancerName: 'Angelina Jolie',
      freelancerAvatar: 'assets/images/freelancers/freelancer_2.png',
      serviceName: 'Mobile Apps Design',
      price: 'Rp. 290.000',
      deadline: '17 Agustus 2025',
      status: 'Pending',
      note: '',
    ),
  ];

  List<OrderModel> getByStatus(String status) {
    if (status == 'Active') return orders;
    return orders.where((o) => o.status == status).toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return const Color(0xFF90CAF9);
      case 'Pending':
        return const Color(0xFFEC407A);
      case 'Completed':
        return const Color(0xFF66BB6A);
      case 'Cancelled':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF90CAF9);
    }
  }
}
