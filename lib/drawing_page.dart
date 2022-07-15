import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drawing_app/drawn_line.dart';
import 'package:drawing_app/sketcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  GlobalKey _globalKey = new GlobalKey();
  List<DrawnLine> lines = <DrawnLine>[];
  List<Obstruction> obstructions = [];
  DrawnLine line;
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;
  TransformationController cont = TransformationController();
  bool enableEditing = true;

  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  Future<void> save() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      var saved = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: DateTime.now().toIso8601String() + ".png",
        isReturnImagePathOfIOS: true,
      );
      print(saved);
    } catch (e) {
      print(e);
    }
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
      obstructions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Container(
        // width: 400,
        // height: 800,
        child: Align(
          alignment: Alignment.center,
          child: InteractiveViewer(
            transformationController: cont,
            child: Stack(
              children: [
                buildAllPaths(context),
                buildObstructions(context),
                buildCurrentPath(context),
                buildColorToolbar(),
                buildStrokeToolbar(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            enableEditing = !enableEditing;
          });
        },
        child: Text(enableEditing.toString()),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: enableEditing ? onPanStart : null,
      onPanUpdate: enableEditing ? onPanUpdate : null,
      onPanEnd: enableEditing ? onPanEnd : null,
      onTapDown: onTapDown,
      child: RepaintBoundary(
        child: Container(
          width: 400,
          height: 800,
          padding: EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(
                  lines: [line],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: 400,
        height: 800,
        color: Colors.transparent,
        padding: EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines,
              ),
            );
          },
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    print("event: onPan start");
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.globalPosition);
    line = DrawnLine([point], selectedColor, selectedWidth);
  }

  void onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.globalPosition);

    List<Offset> path = List.from(line.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line);

    linesStreamController.add(lines);
  }

  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 100.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(15.0),
        ],
      ),
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWidth = strokeWidth;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(
              color: selectedColor, borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 40.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildClearButton(),
          Divider(
            height: 10.0,
          ),
          buildSaveButton(),
          Divider(
            height: 20.0,
          ),
          buildColorButton(Colors.red),
          buildColorButton(Colors.blueAccent),
          buildColorButton(Colors.deepOrange),
          buildColorButton(Colors.green),
          buildColorButton(Colors.lightBlue),
          buildColorButton(Colors.black),
          buildColorButton(Colors.white),
        ],
      ),
    );
  }

  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color,
        child: Container(),
        onPressed: () {
          setState(() {
            selectedColor = color;
          });
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: save,
      child: CircleAvatar(
        child: Icon(
          Icons.save,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: CircleAvatar(
        child: Icon(
          Icons.create,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  void onTapDown(TapDownDetails details) {
    var type = ObstructionType.TREE;
    setState(() {
      obstructions.add(
        Obstruction(
          position: details.localPosition,
          type: type,
        ),
      );
    });
  }

  Widget buildObstructions(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 400,
        height: 800,
        padding: EdgeInsets.all(4.0),
        color: Colors.blue[100],
        alignment: Alignment.center,
        child: Stack(
          children: obstructions
              .map((e) => Positioned(
                    top: e.position.dy,
                    left: e.position.dx,
                    child: Container(
                      color: Colors.red,
                      height: 5,
                      width: 5,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
