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
    print(Get.height);
    print(Get.width);
    return Scaffold(
      backgroundColor: Colors.green, // const Color(0xFFFCFAF2),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Draw'),
        backgroundColor: const Color(0xFF277A63),
        actions: [
          IconButton(
            onPressed: controller.undo,
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: Center(
        child: Container(
          // padding: const EdgeInsets.only(
          // top: MediaQuery.of(context).padding.top,
          //     ),
          color: Colors.white,
          child: AspectRatio(
            aspectRatio: 1 / 1.7037,
            child: Stack(
              fit: StackFit.expand,
              children: const [
                DrawingPreviousLinesBuilder(), //will draw lines
                DrawingCurrentLinesBuilder(), //will draw line
                DrawingGestureDetectorBuilder(), //detect gesture and draw accordingly
                ComponentBuilder(), //build all component
                SideComponentBuilder(), //side bar components
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawingGestureDetectorBuilder extends GetView<HomeController> {
  const DrawingGestureDetectorBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: controller.globalKey,
      onScaleStart: controller.onScaleStart,
      onScaleUpdate: controller.onScaleUpdate,
      onScaleEnd: controller.onScaleEnd,
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
                          if (controller.selectedCustomComponent.value == c)
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
                          if (controller.selectedCustomComponent.value == c)
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: IconButton(
                                splashRadius: 20,
                                icon: Icon(
                                  CupertinoIcons.add_circled_solid,
                                  size: 22,
                                  color: Colors.red.shade700,
                                ),
                                onPressed: () => controller.deleteComponent(c),
                              ),
                            ),
                          if (controller.selectedCustomComponent.value == c)
                            Positioned(
                              left: -20,
                              bottom: -20,
                              child: IconButton(
                                splashRadius: 20,
                                icon: Icon(
                                  Icons.remove_circle,
                                  size: 22,
                                  color: Colors.red.shade700,
                                ),
                                onPressed: () => controller.deleteComponent(c),
                              ),
                            ),
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
    return Padding(
      padding: const EdgeInsets.only(right: 20),
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
          const SizedBox(height: 20),
          SizedBox(height: Get.height * 0.10),
        ],
      ),
    );
  }
}
