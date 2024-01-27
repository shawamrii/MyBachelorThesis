import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lock_tracker/services/shapes.dart';


enum Language { DE, EN }

class ConfigData with ChangeNotifier {
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
    this.maxPasswortLaenge = 1,
    this.shapeType = ShapeType.circle,
    this.shapeSize = 25,
    this.movementDuration = 3,
    this.speed = 3,
    this.shapeColor = Colors.white,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.black,
    this.password = "",
    this.language = Language.DE,
    this.lineWidth=1.0,
    this.numberOfShapes=10,
  });

  // this method to update configdataJSON data
  void updateWithJson(Map<String, dynamic> json) {
    maxPasswortLaenge = json['Password length'] ?? maxPasswortLaenge;

    // Assuming shapeType is sent as a string like 'circle' or 'square'
    shapeType = ShapeType.values.firstWhere(
            (e) => e.toString().split('.').last == json['shapeType'],
        orElse: () => shapeType);

    shapeSize = json['shapeSize']?.toDouble() ?? shapeSize;

    movementDuration = json['movementDuration'] ?? movementDuration;
    speed = json['speed']?.toDouble() ?? speed;
    // For color, assuming they are sent as strings like '#ffffff'
    textColor = _parseColor(json['textColor']) ?? textColor;
    shapeColor = _parseColor(json['shapeColor']) ?? shapeColor;
    backgroundColor = _parseColor(json['backgroundColor']) ?? backgroundColor;


    password = json['password'] ?? password;
    // For language, assuming it is sent as 'DE' or 'EN'
    language = Language.values.firstWhere(
            (e) => e.toString().split('.').last == json['language'],
        orElse: () => language);
    lineWidth = json['lineWidth']?.toDouble() ?? lineWidth;
    numberOfShapes = json['numberOfShapes']?.toInt() ?? numberOfShapes;
    notifyListeners();
  }

  Color _parseColor(String colorString) {
    // Pattern matches '0xff000000' part in 'Color(0xff000000)'
    final RegExp colorRegExp = RegExp(r'0x[0-9a-fA-F]+');
    final match = colorRegExp.firstMatch(colorString);

    if (match != null) {
      return Color(int.parse(match.group(0)!));
    } else {
      // Return a default color if parsing fails
      return Colors.black;
    }
  }

  Map<String, dynamic>  toJson() {
    return {
      "Event": "Settings",
      'Password length': maxPasswortLaenge,
      'shapeType': shapeType.toString().split('.').last,
      'numberOfShapes': numberOfShapes,
      'shapeSize': shapeSize,
      'lineWidth': lineWidth,
      'movementDuration': movementDuration,
      'speed': speed,
      'textColor': '#${textColor?.value.toRadixString(16).padLeft(8, '0')}',
      'shapeColor': '#${shapeColor?.value.toRadixString(16).padLeft(8, '0')}',
      'backgroundColor': '#${backgroundColor?.value.toRadixString(16).padLeft(8, '0')}',
      //'password': password,
      'language': language.toString().split('.').last,
      "Timestamp": DateTime.now().toIso8601String(),
    };
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
  void updateLineWidth(double width) {
    lineWidth = width;
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
