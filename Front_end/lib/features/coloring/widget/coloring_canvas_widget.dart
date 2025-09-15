import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/coloring_controller.dart';

class ColoringCanvas extends StatelessWidget {
  final ColoringController controller;

  const ColoringCanvas({required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Only render if image is loaded
      if (controller.loadedImage == null) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final image = controller.loadedImage!;
      final strokes = List<List<Offset>>.from(controller.strokeHistory);
      final colors = List<Color>.from(controller.colorHistory);
      final brushSizes = List<double>.from(controller.brushSizeHistory);
      final currentStroke = List<Offset>.from(controller.currentStroke);
      final currentColor = controller.selectedColor.value;
      final currentBrushSize = controller.brushSize.value;

      return GestureDetector(
        onPanStart: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset localOffset = box.globalToLocal(details.globalPosition);
          controller.addPoint(localOffset);
        },
        onPanUpdate: (details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset localOffset = box.globalToLocal(details.globalPosition);
          controller.addPoint(localOffset);
        },
        onPanEnd: (details) {
          controller.startNewStroke();
        },
        child: CustomPaint(
          painter: ColoringPainter(
            image: image,
            strokes: strokes,
            colors: colors,
            brushSizes: brushSizes,
            currentStroke: currentStroke,
            currentColor: currentColor,
            currentBrushSize: currentBrushSize,
          ),
          size: Size.infinite,
        ),
      );
    });
  }
}

class ColoringPainter extends CustomPainter {
  final ui.Image image;
  final List<List<Offset>> strokes;
  final List<Color> colors;
  final List<double> brushSizes;
  final List<Offset> currentStroke;
  final Color currentColor;
  final double currentBrushSize;

  ColoringPainter({
    required this.image,
    required this.strokes,
    required this.colors,
    required this.brushSizes,
    required this.currentStroke,
    required this.currentColor,
    required this.currentBrushSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    final double scaleX = size.width / image.width;
    final double scaleY = size.height / image.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double scaledWidth = image.width * scale;
    final double scaledHeight = image.height * scale;

    // Center the image
    final double offsetX = (size.width - scaledWidth) / 2;
    final double offsetY = (size.height - scaledHeight) / 2;

    final Rect srcRect =
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final Rect dstRect =
        Rect.fromLTWH(offsetX, offsetY, scaledWidth, scaledHeight);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    for (int i = 0; i < strokes.length; i++) {
      final List<Offset> stroke = strokes[i];
      final Color strokeColor = colors[i];
      final double strokeSize = brushSizes.length > i ? brushSizes[i] : 5.0;

      final Paint paint = Paint()
        ..color = strokeColor
        ..strokeWidth = strokeSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      _drawStroke(canvas, stroke, paint);
    }

    if (currentStroke.isNotEmpty) {
      final Paint paint = Paint()
        ..color = currentColor
        ..strokeWidth = currentBrushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      _drawStroke(canvas, currentStroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> stroke, Paint paint) {
    if (stroke.isEmpty) return;

    if (stroke.length == 1) {
      // Draw a single point as a circle
      canvas.drawCircle(stroke.first, paint.strokeWidth / 2,
          paint..style = PaintingStyle.fill);
      return;
    }

    final Path path = Path();
    path.moveTo(stroke.first.dx, stroke.first.dy);

    for (int i = 1; i < stroke.length; i++) {
      if (i == 1) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      } else {
        final previousPoint = stroke[i - 1];
        final currentPoint = stroke[i];

        final controlPoint = Offset(
          (previousPoint.dx + currentPoint.dx) / 2,
          (previousPoint.dy + currentPoint.dy) / 2,
        );

        path.quadraticBezierTo(
          previousPoint.dx,
          previousPoint.dy,
          controlPoint.dx,
          controlPoint.dy,
        );
      }
    }

    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
