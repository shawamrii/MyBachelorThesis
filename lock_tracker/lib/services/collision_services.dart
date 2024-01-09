import 'dart:ui';

import 'shapes.dart';

void checkEdgeCollisionsForCircles(List<Circle> circles, Size screenSize) {
  for (int i = 0; i < circles.length; i++) {
    Circle circle = circles[i];

    // Check left edge
    if (circle.position.dx - circle.radius < 0 && circle.velocity.dx < 0) {
      circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
    }

    // Check right edge
    if (circle.position.dx + circle.radius > screenSize.width && circle.velocity.dx > 0) {
      circle.velocity = Offset(-circle.velocity.dx, circle.velocity.dy);
    }

    // Check top edge
    if (circle.position.dy - circle.radius < 0 && circle.velocity.dy < 0) {
      circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
    }

    // Check bottom edge
    if (circle.position.dy + circle.radius > screenSize.height && circle.velocity.dy > 0) {
      circle.velocity = Offset(circle.velocity.dx, -circle.velocity.dy);
    }
  }
}

void checkCollisionsForCircles(List<Circle> circles,Size screenSize) {
  for (int i = 0; i < circles.length; i++) {
    for (int j = i + 1; j < circles.length; j++) {
      Circle circle1 = circles[i];
      Circle circle2 = circles[j];
      double distance = (circle1.position - circle2.position).distance;
      if (distance < circle1.radius + circle2.radius) {
        // Calculate the normal vector from the collision using custom normalize function
        Offset collisionNormal = normalize(circle1.position - circle2.position);

        // Calculate the relative velocity
        Offset relativeVelocity = circle1.velocity - circle2.velocity;

        // Calculate the dot product of the relative velocity and the collision normal
        double dotProduct = relativeVelocity.dx * collisionNormal.dx + relativeVelocity.dy * collisionNormal.dy;

        // Calculate the collision response for each circle's velocity
        if (dotProduct < 0) {
          Offset response = collisionNormal * dotProduct;
          circle1.velocity -= response;
          circle2.velocity += response;
        }
      }
    }
  }
}

void checkEdgeCollisionsForSquares(List<Square> squares,Size screenSize) {
  for (int i = 0; i < squares.length; i++) {
    Square square = squares[i];
    double halfSide = square.sideLength / 2.0;

    // Check left edge
    if (square.position.dx - halfSide < 0 && square.velocity.dx < 0) {
      square.velocity = Offset(-square.velocity.dx, square.velocity.dy);
    }

    // Check right edge
    if (square.position.dx + halfSide > screenSize.width && square.velocity.dx > 0) {
      square.velocity = Offset(-square.velocity.dx, square.velocity.dy);
    }

    // Check top edge
    if (square.position.dy - halfSide < 0 && square.velocity.dy < 0) {
      square.velocity = Offset(square.velocity.dx, -square.velocity.dy);
    }

    // Check bottom edge
    if (square.position.dy + halfSide > screenSize.height && square.velocity.dy > 0) {
      square.velocity = Offset(square.velocity.dx, -square.velocity.dy);
    }
  }
}
void checkCollisionsForSquares(List<Square> squares) {
  for (int i = 0; i < squares.length; i++) {
    for (int j = i + 1; j < squares.length; j++) {
      Square square1 = squares[i];
      Square square2 = squares[j];

      // Horizontal and vertical distance between squares' centers
      double dx = square1.position.dx - square2.position.dx;
      double dy = square1.position.dy - square2.position.dy;

      // Minimum distance for which the squares are touching edge-to-edge
      double minDistX = (square1.sideLength + square2.sideLength) / 2.0;
      double minDistY = (square1.sideLength + square2.sideLength) / 2.0;

      if (dx.abs() < minDistX && dy.abs() < minDistY) {
        // Calculate the normal vector from the collision
        Offset collisionNormal = normalize(Offset(dx, dy));

        // Calculate the relative velocity
        Offset relativeVelocity = square1.velocity - square2.velocity;

        // Calculate the dot product of the relative velocity and the collision normal
        double dotProduct = relativeVelocity.dx * collisionNormal.dx + relativeVelocity.dy * collisionNormal.dy;

        // Calculate the collision response for each square's velocity
        if (dotProduct < 0) {
          Offset response = collisionNormal * dotProduct;
          square1.velocity -= response;
          square2.velocity += response;
        }
      }
    }
  }
}
// Move method, Collision checks, and other square-specific methods
Offset normalize(Offset offset) {
  double length = offset.distance;
  if (length == 0) return const Offset(0, 0);
  return Offset(offset.dx / length, offset.dy / length);
}


