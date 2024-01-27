import 'dart:math';
import 'package:flutter/material.dart';

enum ShapeType {
  circle,
  square,
}

abstract class Shape {
  static final Random random = Random();
  Offset position;
  Offset velocity;
  String id;
  late Color? shapeColor;
  late Color? textColor;
  VoidCallback onTap;
  double lastDirectionChangeTime = 0.0;
  ShapeType shapeType;
  static final List<Offset> directions = [
    const Offset(1, 0), // Right
    const Offset(-1, 0), // Left
    const Offset(0, 1), // Down
    const Offset(0, -1), // Up
    const Offset(1, 1), // Down-Right
    const Offset(1, -1), // Up-Right
    const Offset(-1, 1), // Down-Left
    const Offset(-1, -1), // Up-Left
  ];

  Shape({
    required this.position,
    required this.velocity,
    required this.id,
    required this.shapeColor,
    required this.textColor,
    required this.onTap,
    this.shapeType = ShapeType.circle,
  });

  void move(Size screenSize, double speed, double animationProgress,
      ShapeType shapeType);

}

class Circle extends Shape {
  double radius;

  Circle({
    required Offset position,
    required this.radius,
    required Offset velocity,
    required String id,
    required VoidCallback onTap,
    required Color? shapeColor,
    required Color? textColor,
  }) : super(
          position: position,
          velocity:
              Shape.directions[Shape.random.nextInt(Shape.directions.length)],
          id: id,
          shapeColor: shapeColor ?? Colors.blue,
          textColor: textColor ?? Colors.white,
          onTap: onTap,
        );

// Move method, Collision checks, and other circle-specific methods
  @override
  void move(Size screenSize, double speed, double animationProgress,
      ShapeType shapeType) {
    Random random = Random();


    // If 30% of the total move duration has passed since the last direction change
    if (animationProgress >= (lastDirectionChangeTime + 0.3) &&
        animationProgress < (lastDirectionChangeTime + 0.31)) {
      velocity = Shape.directions[random.nextInt(Shape.directions.length)];
      lastDirectionChangeTime = animationProgress;
    }

    // Handle collision with screen edges
    Offset newPosition = position + velocity * speed;
    if ((newPosition.dx - radius < 0 ||
        newPosition.dx + radius > screenSize.width)) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if ((newPosition.dy - radius < 0 ||
        newPosition.dy + radius > screenSize.height)) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }
    position = position + velocity * speed;
  }
}

class Square extends Shape {
  double sideLength;

  Square({
    required Offset position,
    required this.sideLength,
    required Offset velocity,
    required String id,
    required VoidCallback onTap,
    required Color? shapeColor,
    required Color? textColor,
  }) : super(
          position: position,
          velocity: velocity,
          id: id,
          shapeColor: shapeColor ?? Colors.blue,
          textColor: textColor ?? Colors.limeAccent,
          onTap: onTap,
        );

  @override
  void move(Size screenSize, double speed, double animationProgress,
      ShapeType shapeType) {
    Random random = Random();

    // If 30% of the total move duration has passed since the last direction change
    if (animationProgress >= (lastDirectionChangeTime + 0.3) &&
        animationProgress < (lastDirectionChangeTime + 0.31)) {
      velocity = Shape.directions[random.nextInt(Shape.directions.length)];
      lastDirectionChangeTime = animationProgress;
    }

    // Handle collision with screen edges
    Offset newPosition = position + velocity * speed;
    if ((newPosition.dx < 0 ||
        newPosition.dx + sideLength > screenSize.width)) {
      velocity = Offset(-velocity.dx, velocity.dy);
    }
    if ((newPosition.dy < 0 ||
        newPosition.dy + sideLength > screenSize.height)) {
      velocity = Offset(velocity.dx, -velocity.dy);
    }

    position = position + velocity * speed;
  }
}

class ShapePainter extends CustomPainter {
  final List<Shape> shapes;
  Map<String, TextPainter> textPaintersCache = {};
  final bool shouldRepaintFlag;
  final double lineWidth;
  final Size screenSize;
  ShapePainter(this.shapes, this.shouldRepaintFlag,this.lineWidth, this.screenSize);

  int calculateGridWidth(int totalShapes) {
    int sqrtValue = sqrt(totalShapes).floor();
    while (totalShapes % sqrtValue != 0) {
      sqrtValue--;
    }
    return sqrtValue;
  }
/*
  void initializeGridPositions(List<Shape> shapes, Size screenSize) {
    int totalShapes = shapes.length;
    int gridWidth = calculateGridWidth(totalShapes);
    int gridHeight = (totalShapes / gridWidth).ceil();

    double spacingX = screenSize.width / gridWidth;
    double spacingY = screenSize.height / gridHeight;

    for (int i = 0; i < totalShapes; i++) {
      int row = i ~/ gridWidth;
      int col = i % gridWidth;

      double posX = spacingX * col + spacingX / 2; // Zentrum des Gitters
      double posY = spacingY * row + spacingY / 2; // Zentrum des Gitters

      shapes[i].position = Offset(posX, posY);
    }
  }
*/

  @override
  void paint(Canvas canvas, Size size) {
    //initializeGridPositions(shapes, screenSize);
    final paint = Paint();
    int gridWidth = calculateGridWidth(shapes.length);

    // Setze die Paint-Eigenschaften
    paint.strokeWidth = lineWidth;
    paint.style = PaintingStyle.fill;
    paint.color = shapes[0].shapeColor ?? Colors.black;

    if (lineWidth != 0.0) {
      for (int i = 0; i < shapes.length; i++) {
        // Verbinde mit dem rechten Nachbarn oder dem entsprechenden linken, wenn am rechten Rand
        int rightNeighbor = (i + 1) % gridWidth == 0 ? i + 1 - gridWidth : i + 1;
        if (rightNeighbor < shapes.length) {
          canvas.drawLine(shapes[i].position, shapes[rightNeighbor].position, paint);
        }

        // Verbinde mit dem unteren Nachbarn oder dem entsprechenden oberen, wenn am unteren Rand
        int bottomNeighbor = i + gridWidth >= shapes.length ? i + gridWidth - shapes.length : i + gridWidth;
        canvas.drawLine(shapes[i].position, shapes[bottomNeighbor].position, paint);
      }
    }

    // Then, draw each shape and its text
    // Paint for the shape border
    for (Shape shape in shapes) {
    if (shape is Circle) {
        canvas.drawCircle(shape.position, shape.radius, paint);
      } else if (shape is Square) {
        final rect = Rect.fromCenter(
          center: shape.position,
          width: shape.sideLength,
          height: shape.sideLength,
        );
        canvas.drawRect(rect, paint);

    }

      // Draw the shape ID as text
      final textPainter = _getTextPainter(shape.id, shape.textColor);
      final offset = Offset(
          shape.position.dx - (textPainter.width / 2),
          shape.position.dy - (textPainter.height / 2)
      );
      textPainter.paint(canvas, offset);
    }

  }
  TextPainter _getTextPainter(String text, Color? textColor) {
    Shape shape =shapes[0];
    double newfontSize =16;
    if(shape is Circle) {newfontSize = shape.radius*0.7;}
    if(shape is Square) {newfontSize = shape.sideLength*0.7;}
    if (!textPaintersCache.containsKey(text)) {
      final textStyle = TextStyle(
          color: textColor,
          fontSize: newfontSize,
          fontWeight: FontWeight.bold // Add bold style here
      );
      final textSpan = TextSpan(text: text, style: textStyle);
      final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      textPainter.layout();
      textPaintersCache[text] = textPainter;
    }
    return textPaintersCache[text]!;
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Implement logic to determine if repainting is needed
    return shouldRepaintFlag;
  }
}

