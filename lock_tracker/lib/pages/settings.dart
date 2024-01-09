// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';
import '../services/screen_infos.dart';
import '../services/shapes.dart';
import 'instructios.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  List<Map<String, dynamic>> jsonLogMessages = [];
  late ServerConnectivityService connectivityService;
  @override
  void initState() {
    super.initState();
    connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    Map<String, dynamic> logMessage = {
      "Event": "Setting Screen starts",
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    // Postpone the async call until after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async => _initAsync());
  }

  @override
  void dispose() {
    // Dispose of the controllers when the state is disposed
    super.dispose();
  }

  Future<void> _initAsync() async {
    if (mounted) {
      Map<String, dynamic> infos =
          await saveInfosAsJson(context, connectivityService.filename);
      jsonLogMessages.add(infos);
    }
  }

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.black,
    Colors.white,
    Colors.teal,
  ];

  Future<void> saveAndGo(ServerConnectivityService connectivityService, ConfigData configData) async {
    Map<String, dynamic> logMessage = {
      "Event": "Setting Screen ends",
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    if (mounted) {
      await sendJsonToServer( jsonLogMessages, "Setting",connectivityService);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const AcceptanceScreen(
        ),
      ));
    }
  }

  double calculateMaxShapeSize(int numberOfShapes) {
    if (numberOfShapes == 0) {
      return 25;
    } else {
      // Here we get the actual screen size from the MediaQuery
      Size actualScreenSize = MediaQuery.of(context).size;

      // Get the height of the status bar
      double statusBarHeight = MediaQuery.of(context).padding.top;

      // Get the height of the AppBar
      double appBarHeight = kToolbarHeight; // default height

      // Calculate the height without the status bar and the AppBar
      double heightWithoutAppBar =
          actualScreenSize.height - statusBarHeight - appBarHeight;

      // Width remains the same
      double widthWithoutAppBar = actualScreenSize.width;
      final int numShapesSide = sqrt(numberOfShapes).ceil();
      // Calculate maximum size for each shape
      final maxShapeWidth = widthWithoutAppBar / numShapesSide;
      final maxShapeHeight = heightWithoutAppBar / numShapesSide;
      return (min(maxShapeWidth / 2, maxShapeHeight / 2)).roundToDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    final configData = Provider.of<ConfigData>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Einstellungen")),
      body: Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(20.0),
          children: [
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(
                labelText: 'Passwort Länge: ${configData.maxPasswortLaenge}',
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(
                  text: configData.maxPasswortLaenge.toString()),
              onChanged: (String value) {
                final int? newValue = int.tryParse(value);
                if (newValue != null && newValue >= 1 && newValue <= 20) {
                  configData.updateMaxPasswordLength(newValue);
                  int numberOfshapes = configData.calculateNumberOfShapes(newValue);
                  configData.updateNumberOfShapes(numberOfshapes);
                  double sizeOfshapes = calculateMaxShapeSize(numberOfshapes);
                  configData.updateShapeSize(sizeOfshapes);
/*                  setState(() {
                    _configData.maxPasswortLaenge = newValue;
                    _configData.numberOfShapes = _configData
                        .berechneNumberOfShapes(_configData.maxPasswortLaenge);


                    _configData.shapeSize =
                        calculateMaxShapeSize(_configData.numberOfShapes);
                  });*/
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(
                labelText: 'Anzahl der Objekte: ${configData.numberOfShapes}',
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(
                  text: configData.numberOfShapes.toString()),
              onChanged: (String value) {
                final int? newValue = int.tryParse(value);
                if (newValue != null && newValue >= 1 && newValue <= 30) {
                  configData.updateNumberOfShapes(newValue);
                  double sizeOfshapes = calculateMaxShapeSize(newValue);
                  configData.updateShapeSize(sizeOfshapes);
/*
                  setState(() {
                    _configData.numberOfShapes = newValue;
                    _configData.shapeSize =
                        calculateMaxShapeSize(_configData.numberOfShapes);
                  });
*/
                }
              },
            ),
            const Text("Darstellung"),
            DropdownButton<ShapeType>(
              value: configData.shapeType,
              items: const <DropdownMenuItem<ShapeType>>[
                DropdownMenuItem(
                  value: ShapeType.circle,
                  child: Text('Kreis'),
                ),
                DropdownMenuItem(
                  value: ShapeType.square,
                  child: Text('Quadrat'),
                ),
              ],
              onChanged: (ShapeType? newValue) {
                configData.updateShapeType(newValue??ShapeType.square);
/*                // setState(() {
                //   _configData.shapeType = newValue!;
                // });*/
              },
            ),
            Text("Größe: ${configData.shapeSize}"),
            Slider(
              value: configData.shapeSize.roundToDouble(),
              onChanged: (double newValue) {
                configData.updateShapeSize(newValue);
/*
                setState(() {
                  _configData.shapeSize = newValue.roundToDouble();
                });
*/
              },
              min: 1,
              max: max(
                  calculateMaxShapeSize(configData.numberOfShapes)
                      .roundToDouble(),
                  10.1),
              divisions: max(
                  calculateMaxShapeSize(configData.numberOfShapes).toInt() - 1,
                  1),
              label: configData.shapeSize.toString(),
            ),
            Text("Animationsdauer: ${configData.movementDuration}"),
            Slider(
              value: configData.movementDuration.toDouble(),
              onChanged: (double newValue) {
                configData.updateMovementDuration(newValue.toInt());
/*                setState(() {
                  _configData.movementDuration = newValue.toInt();
                });*/
              },
              min: 1,
              max: 10,
              divisions: 9,
              label: configData.movementDuration.toString(),
            ),
            Text("Geschwindigkeit: ${configData.speed}"),
            Slider(
              value: configData.speed,
              onChanged: (double newValue) {
                configData.updateSpeed(newValue);
/*                setState(() {
                  _configData.speed = newValue;
                });*/
              },
              min: 0.5,
              max: 5,
              divisions: 9,
              label: configData.speed.toString(),
            ),
            const Text('Hintergrundfarbe'),
            DropdownButton<Color>(
              value: configData.backgroundColor,
              hint: const Text('Hintergrundfarbe'),
              onChanged: (Color? color) {
                configData.updateBackgroundColor(color??Colors.black);
/*                setState(() {
                  _configData.backgroundColor = color ?? Colors.black;
                });*/
              },
              items: _availableColors.map((Color color) {
                return DropdownMenuItem<Color>(
                  value: color,
                  child: Container(
                    width: 50,
                    height: 20,
                    color: color,
                  ),
                );
              }).toList(),
            ),
            const Text('Textfarbe'),
            DropdownButton<Color>(
              value: configData.textColor,
              hint: const Text('Textfarbe'),
              onChanged: (Color? color) {
                if (mounted) {
                  configData.updateTextColor(color??Colors.black);
/*                  setState(() {
                    _configData.textColor = color ?? Colors.black;
                    });*/
                }
              },
              items: _availableColors.map((Color color) {
                return DropdownMenuItem<Color>(
                  value: color,
                  child: Container(
                    width: 50,
                    height: 20,
                    color: color,
                  ),
                );
              }).toList(),
            ),
            const Text('Objektsfarbe'),
            DropdownButton<Color>(
              value: configData.shapeColor,
              hint: const Text('Objektsfarbe'),
              onChanged: (Color? color) {
                configData.updateShapeColor(color??Colors.white);
/*                setState(() {
                  _configData.shapeColor = color ?? Colors.white;
                  });*/
              },
              items: _availableColors.map((Color color) {
                return DropdownMenuItem<Color>(
                  value: color,
                  child: Container(
                    width: 50,
                    height: 20,
                    color: color,
                  ),
                );
              }).toList(),
            ),
            const Text("Sprache der Umfragen"),
            DropdownButton<Language>(
              value: configData.language,
              items: const <DropdownMenuItem<Language>>[
                DropdownMenuItem(
                  value: Language.EN,
                  child: Text('Englisch'),
                ),
                DropdownMenuItem(
                  value: Language.DE,
                  child: Text('Deutsch'),
                ),
              ],
              onChanged: (Language? newValue) {
                configData.updateLanguage(newValue??Language.DE);
/*                setState(() {
                  _configData.language = newValue!;
                });*/
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveAndGo(connectivityService,configData);
              },
              child: const Text("Speichern"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
