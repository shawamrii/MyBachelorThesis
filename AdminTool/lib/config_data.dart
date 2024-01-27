import 'dart:math';
import 'package:flutter/material.dart';

enum ShapeType {
  circle,
  square,
}
enum Language { DE, EN }
class ConfigData {
  int maxPasswortLaenge;
  ShapeType shapeType;
  late int numberOfShapes;
  double shapeSize;
  //bool withLines;
  double lineWidth;
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
    this.lineWidth=0.0,
  }) {
    numberOfShapes = calculateNumberOfShapes(maxPasswortLaenge);
  }

    Map<String, dynamic>  toJson() {
    return {
      'Password length': maxPasswortLaenge,
      'shapeType': shapeType.toString().split('.').last,
      'numberOfShapes': numberOfShapes,
      'shapeSize': shapeSize,
      'lineWidth': lineWidth,
      'movementDuration': movementDuration,
      'speed': speed,
      'textColor': textColor.toString(),
      'shapeColor': shapeColor.toString(),
      'backgroundColor': backgroundColor.toString(),
      //'password': password,
      'language': language.toString().split('.').last,
    };
  }


  void updateMaxPasswordLength(int length) {
    maxPasswortLaenge = length;
    numberOfShapes = calculateNumberOfShapes(length);
  }

  void updateShapeType(ShapeType type) {
    shapeType = type;
  }

  void updateNumberOfShapes(int shapes) {
    numberOfShapes = shapes;
  }

  void updateShapeSize(double size) {
    shapeSize = size;
  }

  void updateMovementDuration(int duration) {
    movementDuration = duration;
  }

  void updateSpeed(double newSpeed) {
    speed = newSpeed;
  }

  void updateTextColor(Color color) {
    textColor = color;
  }

  void updateShapeColor(Color color) {
    shapeColor = color;
  }

  void updateBackgroundColor(Color color) {
    backgroundColor = color;
  }

  void updatePassword(String newPass) {
    password = newPass;
  }
  void updateLineWidth(double width) {
    lineWidth = width;
  }

  void updateLanguage(Language newLang) {
    language = newLang;
  }

  int calculateNumberOfShapes(int maxPasswortLaenge) {
    // Assuming this is your existing logic
    return min(pow(10000, 1 / maxPasswortLaenge).round(), 30);
  }

}
