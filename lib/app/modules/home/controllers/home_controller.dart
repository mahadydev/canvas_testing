import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/custom_component.dart';
import '../../../models/drawn_line.dart';

class HomeController extends GetxController {
  final GlobalKey globalKey = GlobalKey();
  //
  RxList<CustomComponent> components = RxList.of(<CustomComponent>[]);
  Rx<List<DrawnLine>> drawnLines = Rx(<DrawnLine>[]);
  Rxn<DrawnLine> line = Rxn();
  Rx<Color> selectedColor = Rx(Colors.black);
  RxDouble selectedWidth = 2.0.obs;

  RxBool eraseMode = false.obs;

  Offset _getPoint(position) {
    RenderBox box = globalKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(position);
  }

  void onPanStart(DragStartDetails details) {
    final Offset point = _getPoint(details.globalPosition);
    debugPrint("event: onPan start $point");

    if (!eraseMode.value) {
      line.value = DrawnLine(
        path: [point],
        color: selectedColor.value,
        width: selectedWidth.value,
      );
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    final Offset point = _getPoint(details.globalPosition);
    debugPrint("event: onPan update $point");

    if (!eraseMode.value) {
      List<Offset> path = List.from(line.value!.path)..add(point);
      line.value = DrawnLine(
        path: path,
        color: selectedColor.value,
        width: selectedWidth.value,
      );
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (!eraseMode.value) {
      debugPrint("event: onPan end");
      drawnLines.value = List.from(drawnLines.value)..add(line.value!);
    }
  }

  addComponentToScreen(String svgPath) {
    if (!eraseMode.value) {
      components.add(
        CustomComponent(
          svgPath: svgPath,
          size: const Size(50, 50),
          position: Offset(Get.width / 3, Get.height / 3),
        ),
      );
    }
  }

  onCustomComponentScaleStart(ScaleStartDetails details, CustomComponent c) {
    if (eraseMode.value) {
      components.remove(c);
    }
  }

  onCustomComponentScaleUpdate(
      ScaleUpdateDetails details, CustomComponent customComponent) {
    if (!eraseMode.value) {
      final Offset point = _getPoint(details.focalPoint);

      CustomComponent temp = customComponent
        ..position = point -
            Offset(
              customComponent.size.width / 3,
              customComponent.size.height / 2,
            );

      int index = components.indexWhere((c) => c == customComponent);
      components[index] = temp;
    }
  }

  void eraseModeSwitch() {
    eraseMode.value = !eraseMode.value;
  }

  void clearAll() {
    drawnLines.value = [];
    components.clear();
    line.value = null;
  }

  undo() {
    if (drawnLines.value.isNotEmpty) {
      drawnLines.update((val) {
        drawnLines.value.removeLast();
        line.value = null;
      });
    }
  }
}
