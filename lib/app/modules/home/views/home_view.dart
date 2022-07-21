import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:golf4u_drawing_test/app/modules/home/painter/sketcher.dart';

import '../../../models/custom_component.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF2),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Draw'),
        backgroundColor: const Color(0xFF277A63),
        actions: [
          IconButton(
            onPressed: controller.undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            onPressed: () => controller.isLockEnabled.value =
                !controller.isLockEnabled.value,
            icon: Obx(
              () => Icon(controller.isLockEnabled.value
                  ? Icons.lock
                  : Icons.lock_open),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(
            () => InteractiveViewer(
              constrained: false,
              minScale: 0.2,
              maxScale: 3,
              panEnabled: controller.isLockEnabled.value,
              scaleEnabled: controller.isLockEnabled.value,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: Container(
                color: Colors.yellow.shade100,
                height: 2000,
                width: 2000,
                child: Stack(
                  fit: StackFit.expand,
                  children: const [
                    DrawingPreviousLinesBuilder(), //will draw lines
                    DrawingCurrentLinesBuilder(), //will draw line
                    DrawingGestureDetectorBuilder(), //detect gesture and draw accordingly
                    ComponentBuilder(), //build all component
                  ],
                ),
              ),
            ),
          ),
          const SideComponentBuilder(),
        ],
      ),
    );
  }
}

class DrawingGestureDetectorBuilder extends GetView<HomeController> {
  const DrawingGestureDetectorBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => !controller.isLockEnabled.value
          ? GestureDetector(
              key: controller.globalKey,
              onScaleStart: controller.onScaleStart,
              onScaleUpdate: controller.onScaleUpdate,
              onScaleEnd: controller.onScaleEnd,
            )
          : const SizedBox(),
    );
  }
}

class DrawingPreviousLinesBuilder extends GetView<HomeController> {
  const DrawingPreviousLinesBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RepaintBoundary(
        child: CustomPaint(
          painter: Sketcher(
            lines: controller.drawnLines.value,
          ),
        ),
      ),
    );
  }
}

class DrawingCurrentLinesBuilder extends GetView<HomeController> {
  const DrawingCurrentLinesBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RepaintBoundary(
        child: CustomPaint(
          painter: Sketcher(
            lines:
                controller.line.value != null ? [controller.line.value!] : [],
          ),
        ),
      ),
    );
  }
}

class ComponentBuilder extends GetView<HomeController> {
  const ComponentBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.components.isEmpty
          ? const SizedBox()
          : Stack(
              children: controller.components
                  .map(
                    (CustomComponent c) => Positioned(
                      top: c.position.dy,
                      left: c.position.dx,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onScaleStart: (d) =>
                                controller.onCustomComponentScaleStart(d, c),
                            onScaleUpdate: (d) =>
                                controller.onCustomComponentScaleUpdate(d, c),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: controller
                                              .selectedCustomComponent.value ==
                                          c
                                      ? Colors.green
                                      : Colors.transparent,
                                ),
                              ),
                              child: SvgPicture.asset(
                                c.svgPath,
                                height: c.size.height,
                                width: c.size.width,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          if (controller.selectedCustomComponent.value ==
                              c) ...[
                            Positioned(
                              left: -20,
                              top: -20,
                              child: IconButton(
                                splashRadius: 20,
                                icon: Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  size: 22,
                                  color: Colors.red.shade700,
                                ),
                                onPressed: () => controller.deleteComponent(c),
                              ),
                            ),
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: IconButton(
                                splashRadius: 20,
                                icon: const Icon(
                                  CupertinoIcons.add_circled_solid,
                                  size: 22,
                                  color: Colors.black87,
                                ),
                                onPressed: () =>
                                    controller.increaseComponentSize(c),
                              ),
                            ),
                            Positioned(
                              left: -20,
                              bottom: -20,
                              child: IconButton(
                                splashRadius: 20,
                                icon: const Icon(
                                  Icons.remove_circle,
                                  size: 22,
                                  color: Colors.black87,
                                ),
                                onPressed: () =>
                                    controller.decreaseComponentSize(c),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class SideComponentBuilder extends GetView<HomeController> {
  const SideComponentBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(right: 20, bottom: Get.height * 0.10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () => controller.addComponentToScreen('assets/flag.svg'),
              child: SvgPicture.asset('assets/flag.svg'),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => controller.addComponentToScreen('assets/tree.svg'),
              child: SvgPicture.asset('assets/tree.svg'),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => controller.addComponentToScreen('assets/sand.svg'),
              child: SvgPicture.asset('assets/sand.svg'),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => controller.addComponentToScreen('assets/water.svg'),
              child: SvgPicture.asset('assets/water.svg'),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => controller.addComponentToScreen('assets/house.svg'),
              child: SvgPicture.asset('assets/house.svg'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(),
              child: SvgPicture.asset('assets/eraser.svg'),
            ),
          ],
        ),
      ),
    );
  }
}
