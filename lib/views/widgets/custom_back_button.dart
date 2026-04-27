import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const CustomBackButton({
    super.key,
    required this.onTap,
    this.color = Colors.white,
  });
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: color,
          size: 28,
        ),
        onPressed: onTap,
      ),
    );
  }
}