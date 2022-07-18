import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;

  DrawnLine({
    required this.path,
    required this.color,
    required this.width,
  });
}
