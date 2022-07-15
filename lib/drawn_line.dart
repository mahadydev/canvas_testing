import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;

  DrawnLine(this.path, this.color, this.width);
}

class Obstruction {
  final Offset position;
  final ObstructionType type;

  Obstruction({
    @required this.position,
    @required this.type,
  });
}

enum ObstructionType { WATER, TREE, SAND, FLAG }
