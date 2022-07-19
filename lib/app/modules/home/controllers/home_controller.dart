import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/custom_component.dart';
import '../../../models/drawn_line.dart';

class HomeController extends GetxController {
  final GlobalKey globalKey = GlobalKey();
  TransformationController transformationController =
      TransformationController();
  //
  RxList<CustomComponent> components = RxList.of(<CustomComponent>[]);
  Rx<List<DrawnLine>> drawnLines = Rx(<DrawnLine>[]);
  Rxn<DrawnLine> line = Rxn();
  Rx<Color> selectedLineColor = Rx(Colors.black);
  RxDouble selectedLineWidth = 2.0.obs;
  Rxn<CustomComponent> selectedCustomComponent = Rxn();

  double drawScale = 1.0;

  //METHODS---------------------------------------------------------
  Offset _getPoint(position) {
    RenderBox box = globalKey.currentContext!.findRenderObject() as RenderBox;
    return box.globalToLocal(position);
  }

  void onScaleStart(ScaleStartDetails details) {
    selectedCustomComponent.value = null;
    final Offset point = _getPoint(details.focalPoint);
    debugPrint("event: onScale start $point");
    line.value = DrawnLine(
      path: [point],
      color: selectedLineColor.value,
      width: selectedLineWidth.value,
    );
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final Offset point = _getPoint(details.focalPoint);
    debugPrint("event: onScale update $point");

    if (details.scale == 1) {
      List<Offset> path = List.from(line.value!.path)..add(point);
      line.value = DrawnLine(
        path: path,
        color: selectedLineColor.value,
        width: selectedLineWidth.value,
      );
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
    debugPrint("event: onScale end");
    if (line.value!.path.length > 1) {
      drawnLines.value = List.from(drawnLines.value)..add(line.value!);
    }
    line.value = null;
  }

  addComponentToScreen(String svgPath) {
    final c = CustomComponent(
      svgPath: svgPath,
      size: const Size(50, 50),
      position: Offset(Get.width / 3, Get.height / 3),
    );

    components.add(c);
    selectedCustomComponent.value = c;
  }

  onCustomComponentScaleStart(
      ScaleStartDetails details, CustomComponent customComponent) {
    selectedCustomComponent.value = customComponent;
  }

  deleteComponent(CustomComponent c) {
    components.remove(c);
  }

  increaseComponentSize(CustomComponent customComponent) {
    var temp = CustomComponent(
      svgPath: customComponent.svgPath,
      size: Size(
        customComponent.size.width + 10,
        customComponent.size.height + 10,
      ),
      position: customComponent.position,
    );
    int index = components.indexWhere((c) => c == customComponent);
    components[index] = temp;
  }

  decreaseComponentSize(CustomComponent customComponent) {
    var temp = CustomComponent(
      svgPath: customComponent.svgPath,
      size: Size(
        customComponent.size.width - 10,
        customComponent.size.height - 10,
      ),
      position: customComponent.position,
    );

    int index = components.indexWhere((c) => c == customComponent);
    components[index] = temp;
  }

  onCustomComponentScaleUpdate(
      ScaleUpdateDetails details, CustomComponent customComponent) {
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

  void clearAll() {
    drawnLines.value = [];
    components.clear();
    line.value = null;
  }

  undo() {
    if (drawnLines.value.isNotEmpty) {
      drawnLines.update((val) {
        drawnLines.value.removeLast();
      });
    }
  }
}
