import 'package:flutter/material.dart';

class Skill {
  final String name;
  final Color color;
  final bool isCustom;

  Skill({
    required this.name,
    this.color = Colors.grey,
    this.isCustom = false,
  });
}