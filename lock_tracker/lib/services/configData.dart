import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lock_tracker/services/shapes.dart';


enum Language { DE, EN }
class ConfigData with ChangeNotifier {
  int maxPasswortLaenge;
  ShapeType shapeType;
  late int numberOfShapes;
  double shapeSize;
  int movementDuration;
  double speed;
  Color? textColor;
  Color? shapeColor;
  Color? backgroundColor;
  String password;
  Language language;

  ConfigData({
    this.maxPasswortLaenge = 4,
    this.shapeType = ShapeType.circle,
    this.shapeSize = 25,
    this.movementDuration = 3,
    this.speed = 3,
    this.shapeColor = Colors.white,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.black,
    this.password = "",
    this.language = Language.DE,
  }) {
    numberOfShapes = calculateNumberOfShapes(maxPasswortLaenge);
  }

  void updateMaxPasswordLength(int length) {
    maxPasswortLaenge = length;
    numberOfShapes = calculateNumberOfShapes(length);
    notifyListeners();
  }

  void updateShapeType(ShapeType type) {
    shapeType = type;
    notifyListeners();
  }

  void updateNumberOfShapes(int shapes) {
    numberOfShapes = shapes;
    notifyListeners();
  }

  void updateShapeSize(double size) {
    shapeSize = size;
    notifyListeners();
  }

  void updateMovementDuration(int duration) {
    movementDuration = duration;
    notifyListeners();
  }

  void updateSpeed(double newSpeed) {
    speed = newSpeed;
    notifyListeners();
  }

  void updateTextColor(Color color) {
    textColor = color;
    notifyListeners();
  }

  void updateShapeColor(Color color) {
    shapeColor = color;
    notifyListeners();
  }

  void updateBackgroundColor(Color color) {
    backgroundColor = color;
    notifyListeners();
  }

  void updatePassword(String newPass) {
    password = newPass;
    notifyListeners();
  }

  void updateLanguage(Language newLang) {
    language = newLang;
    notifyListeners();
  }

  int calculateNumberOfShapes(int maxPasswortLaenge) {
    // Assuming this is your existing logic
    return min(pow(10000, 1 / maxPasswortLaenge).round(), 30);
  }

}
