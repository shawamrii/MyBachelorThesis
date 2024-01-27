// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'apiServices/apiService.dart';
import 'config_data.dart';


class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late ConfigData configData;
  @override
  void initState() {
    super.initState();
    configData = ConfigData();
  }

  @override
  void dispose() {
    // Dispose of the controllers when the state is disposed
    super.dispose();
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

  Future<void> saveAndGo(Map<String, dynamic> data) async {
    if (mounted) {
      final ApiService apiService = ApiService();
      await apiService.sendJsonToServer(data);
      Navigator.of(context).pop();

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
    //update this line please
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
                 setState(() {
                    configData.maxPasswortLaenge = newValue;
                    configData.numberOfShapes = configData.calculateNumberOfShapes(configData.maxPasswortLaenge);


                    configData.shapeSize =
                        calculateMaxShapeSize(configData.numberOfShapes);
                  });
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
                  //  configData.updateNumberOfShapes(newValue);
                  //double sizeOfshapes = calculateMaxShapeSize(newValue);
                  //configData.updateShapeSize(sizeOfshapes);

                  setState(() {
                    configData.numberOfShapes = newValue;
                    configData.shapeSize =
                        calculateMaxShapeSize(configData.numberOfShapes);
                  });

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
                //configData.updateShapeType(newValue??ShapeType.square);
                 setState(() {
                   configData.shapeType = newValue??ShapeType.square;
                 });
              },
            ),
            Text("Linienbreite: ${configData.lineWidth}"),
            Slider(
              value: configData.lineWidth,
              onChanged: (double newValue) {
               // configData.updateLineWidth(newValue);
                setState(() {
                  configData.lineWidth=newValue;
                });
              },
              min: 0.0,
              max: 10.0,
              divisions: 20,
              label: configData.lineWidth.toString(),
            ),
            Text("Größe: ${configData.shapeSize}"),
            Slider(
              value: configData.shapeSize.roundToDouble(),
              onChanged: (double newValue) {
                //configData.updateShapeSize(newValue);
                setState(() {
                  configData.shapeSize=newValue;
                });
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
                //configData.updateMovementDuration(newValue.toInt());
                setState(() {
                  configData.movementDuration = newValue.toInt();
                });
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
                //configData.updateSpeed(newValue);
                setState(() {
                  configData.speed = newValue;
                });
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
                //configData.updateBackgroundColor(color??Colors.black);
                setState(() {
                  configData.backgroundColor = color ?? Colors.black;
                });
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
                  //configData.updateTextColor(color??Colors.black);
                  setState(() {
                    configData.textColor = color ?? Colors.black;
                    });
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
               // configData.updateShapeColor(color??Colors.white);
                setState(() {
                  configData.shapeColor = color ?? Colors.white;
                  });
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
                //configData.updateLanguage(newValue??Language.DE);
                setState(() {
                  configData.language = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveAndGo(configData.toJson());
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
