import 'package:drawing_app/drawn_line.dart';
import 'package:flutter/material.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;
  final List<Obstruction> objects;

  Sketcher({this.lines, this.objects});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
          paint.color = lines[i].color;
          paint.strokeWidth = lines[i].width;
          canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
        }
      }
    }

    // for (var obj in objects) {
    //   switch (obj.type) {
    //     case ObstructionType.SAND:
    //       {}
    //       break;
    //     case ObstructionType.WATER:
    //       {}
    //       break;
    //     case ObstructionType.TREE:
    //       {}
    //       break;
    //     case ObstructionType.FLAG:
    //       {}
    //       break;
    //   }
    // }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
