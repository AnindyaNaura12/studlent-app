import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const FilterButton({
    super.key,
    required this.onTap,
    this.size = 20,
    this.backgroundColor = Colors.orange,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.tune,
            color: iconColor,
            size: size,
          ),
        ),
      ),
    );
  }
}