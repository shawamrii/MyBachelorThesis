// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lock_tracker/pages/settings.dart';
import 'package:provider/provider.dart';
import '../services/collision_services.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';
import '../services/shapes.dart';
import 'bmsSurvey.dart';

class AnimationScreen extends StatefulWidget {
  final int aktuelleWiederholung;
  final Size screenSize;

  const AnimationScreen({
    super.key,
    required this.aktuelleWiederholung,
    required this.screenSize,
  });

  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> jsonLogMessages = [];
  late AnimationController _controller;
  Size screenSize = const Size(200, 300);
  bool isAnimating = false;
  bool isStartButtonVisible = true;
  List<Shape> shapes = [];
  late ShapeType shapeType;

  late Color textColor;
  late Color shapeColor;
  late String password;
  bool startAnimation = false;
  late int aktuelleWiederholung;
  int reloadCounter = 0;
  late ConfigData configData;


  @override
  void initState() {
    super.initState();
    Map<String, dynamic> logMessage = {
      "type": "Animation",
      "Event": "The Animation Screen starts",
      "Round": widget.aktuelleWiederholung,
      "Reload Nr.": reloadCounter,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    configData = Provider.of<ConfigData>(context, listen: false);

//    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      initializeScreen();
    }
    //  });
  }

  void initializeScreen() {
    // Load configurations
    screenSize = widget.screenSize;
    startAnimation = false;
    isAnimating = false;
    isStartButtonVisible = true;
    reloadCounter++;
    password = configData.password;
    aktuelleWiederholung = widget.aktuelleWiederholung;
    textColor = configData.textColor ?? Colors.white;
    shapeColor = configData.shapeColor ?? Colors.blue;
    shapeType = configData.shapeType;
    shapes = _initializeShape(
        screenSize, configData.numberOfShapes, shapeType);

    _controller = AnimationController(
      duration: Duration(seconds: configData.movementDuration),
      vsync: this,
    )..addListener(() {
        if (isAnimating) {
          setState(() {
            checkEdgeCollisions();
            checkCollisions();
            for (Shape shape in shapes) {
              shape.textColor = shapeColor;
              shape.move(screenSize, configData.speed,
                  _controller.value, configData.shapeType);
            }
          });
        }
      });
  }

  List<Shape> _initializeShape(

      Size screenSize, int numberOfShapes, ShapeType shapeType) {
    Random random = Random();
    List<String> availableIds = '0123456789abcdefghijklmnopqrstuvwxyz'
        .replaceFirst(password[aktuelleWiederholung - 1], "")
        .split('');
    List<Shape> shapes = [];
    double shapeSize = shapeType == ShapeType.square
        ? configData.shapeSize * 1.2
        : configData.shapeSize;

    for (int i = 0; i < numberOfShapes; i++) {
      String id;
      if (i == 0) {
        id = password[aktuelleWiederholung - 1];
      } else {
        if (availableIds.isNotEmpty) {
          id = availableIds.removeAt(random.nextInt(availableIds.length));
        } else {
          id = "*"; // Use '*' when no unique IDs are left
        }
      }

      Offset position;
      bool overlaps;
      do {
        overlaps = false;
        // Adjusted to make sure circle is always inside the screen
        position = Offset(
          shapeSize +
              (random.nextDouble() * (screenSize.width - 2 * shapeSize)),
          shapeSize +
              (random.nextDouble() * (screenSize.height - 2 * shapeSize)),
        );
        for (Shape shape in shapes) {
          double distanceToOtherShape;

          if (shapeType == ShapeType.circle && shape is Circle) {
            distanceToOtherShape = (shape.position - position).distance;
            if (distanceToOtherShape < shapeSize * 2) {
              // 2 times radius for circles
              overlaps = true;
              break;
            }
          } else if (shapeType == ShapeType.square && shape is Square) {
            if (position.dx + shapeSize > shape.position.dx &&
                position.dx < shape.position.dx + shapeSize &&
                position.dy + shapeSize > shape.position.dy &&
                position.dy < shape.position.dy + shapeSize) {
              overlaps = true;
              break;
            }
          }
        }
      } while (overlaps);

      if (shapeType == ShapeType.circle) {
        shapes.add(
          Circle(
            position: position,
            radius: shapeSize,
            velocity: Offset(
                random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
            id: id,
            onTap: () async {
              await _onTap("Circle", id,
                  password[aktuelleWiederholung - 1] == id, startAnimation);
            },
            shapeColor: shapeColor,
            textColor: configData.textColor,
          ),
        );
      } else if (shapeType == ShapeType.square) {
        shapes.add(
          Square(
            position: position,
            sideLength: shapeSize,
            velocity: Offset(
                random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
            id: id,
            onTap: () async {
              await _onTap("Square", id,
                  password[aktuelleWiederholung - 1] == id, startAnimation);
            },
            shapeColor: shapeColor,
            textColor: configData.textColor,
          ),
        );
      }
    }
    return shapes;
  }

  void checkEdgeCollisions() {
    if (shapeType == ShapeType.circle) {
      List<Circle> circles = shapes.whereType<Circle>().cast<Circle>().toList();
      checkEdgeCollisionsForCircles(circles, screenSize);
    } else if (shapeType == ShapeType.square) {
      List<Square> squares = shapes.whereType<Square>().cast<Square>().toList();
      checkEdgeCollisionsForSquares(squares, screenSize);
    } else {
      Future.error("Shape is missing");
    }
  }

  void checkCollisions() {
    if (shapeType == ShapeType.circle) {
      List<Circle> circles = shapes.whereType<Circle>().cast<Circle>().toList();
      checkCollisionsForCircles(circles, screenSize);
    } else if (shapeType == ShapeType.square) {
      List<Square> squares = shapes.whereType<Square>().cast<Square>().toList();
      checkCollisionsForSquares(squares);
    } else {
      Future.error("Shape is missing");
    }
  }

  Future<void> _naechsteWiederholung(ServerConnectivityService connectivityService, configData) async {
    if (widget.aktuelleWiederholung < configData.maxPasswortLaenge) {
      Map<String, dynamic> logMessage = {
        "Event": "The Animation Screen ends",
        "Round": widget.aktuelleWiederholung,
        "Reload Nr.": reloadCounter,
        "Timestamp": DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AnimationScreen(
            aktuelleWiederholung: widget.aktuelleWiederholung + 1,
            screenSize: screenSize,
          ),
        ));
      }
    } else {
      // Ende der Wiederholungen
      Map<String, dynamic> logMessage = {
        "Event": "The Animation Screen finished",
        "Round": widget.aktuelleWiederholung,
        "Reload Nr.": reloadCounter,
        "Timestamp": DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
      if (kIsWeb) {
        await sendJsonToServer( jsonLogMessages, "Animation",connectivityService);
      } else {
        await sendJsonToServer( jsonLogMessages, "Animation",connectivityService);
      }
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BmsSurveyWidget(
              index: 2,
            ),
          ),
        );
      } // Go back to the first screen
    }
  }

  @override
  void dispose() {
    _controller.stop(); // Stop the controller if it's still running
    _controller.dispose(); // This line disposes of the AnimationController
    super.dispose();
  }

  Future<void> _close(ServerConnectivityService connectivityService,context) async {
    if (kDebugMode) {
      debugPrint("_close");
    }
    // Close the animation screen
    Map<String, dynamic> logMessage = {
      "Event": "Close button clicked",
      "Round": widget.aktuelleWiederholung,
      "Reload Nr.": reloadCounter,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    if (mounted) {
      if (kIsWeb) {
        await sendJsonToServer( jsonLogMessages, "Animation",connectivityService);
      } else {
        await sendJsonToServer( jsonLogMessages, "Animation",connectivityService);
      }
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ConfigScreen(
        ),
      ));
    }
  }

  Future<void> _refresh() async {
    if (kDebugMode) {
      debugPrint("_refresh");
    }
    Map<String, dynamic> logMessage = {
      "Event": "Reload Button clicked",
      "Reload Nr.": reloadCounter,
      "Round": widget.aktuelleWiederholung,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    setState(() {
      initializeScreen();
    });
  }

  Future<void> _tapDown(TapDownDetails details) async {
    if (kDebugMode) {
      debugPrint("_tapDown");
    }
    Map<String, dynamic> logMessage = {
      "Event": "Animation Screen touched",
      "Reload Nr.": reloadCounter,
      "Position.": details.globalPosition.toString(),
      "Round": widget.aktuelleWiederholung,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
  }

  Future<void> _onTap(
      String shape, String id, bool isPin, bool isStartAnimation) async {
    if (kDebugMode) {
      debugPrint("_onTap");
    }
    if (isStartAnimation) {
      Map<String, dynamic> logMessage = {
        "Event": "$shape touched",
        "ID": id,
        "Reload Nr.": reloadCounter,
        "Round": widget.aktuelleWiederholung,
        "isPin": isPin.toString(),
        "Timestamp": DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
      if (isPin) {
        final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
        await _naechsteWiederholung(connectivityService,configData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You clicked the wrong PIN number!')),
        );
      }
    }
  }

  Future<void> _play() async {
    if (kDebugMode) {
      debugPrint("_play");
    }
    Map<String, dynamic> logMessage = {
      "type": "Animation",
      "Event": "Play button clicked",
      "Round": widget.aktuelleWiederholung,
      "Reload Nr.": reloadCounter,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    // Start the animation
    setState(() {
      //Provider.of<ShapeNotifier>(context, listen: false);
      isAnimating = true;
      isStartButtonVisible = false; // Hide Start button when clicked
      _controller.forward();
    });
    startAnimation = true;
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    final configData = Provider.of<ConfigData>(context, listen: false);
    return Scaffold(
        backgroundColor: configData.backgroundColor ?? Colors.white,
        appBar: AppBar(
          title: Text(
              "Animation ${widget.aktuelleWiederholung} von ${configData.maxPasswortLaenge}"),
          automaticallyImplyLeading: false,
          actions: [
            if (isStartButtonVisible) // Conditionally display the start button
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () async {
                  await _play();
                },
                tooltip: 'Animation abspielen',
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _close(connectivityService,context);
              },
              tooltip: 'Abbrechen',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await _refresh();
              },
              tooltip: 'Aktualisieren',
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) async {
                  await _tapDown(details);
                },
                child: CustomPaint(
                  painter: ShapePainter(
                      shapes,
                      reloadCounter == 1 &&
                          widget.aktuelleWiederholung ==
                              1), // Updated to a more generic painter
                ),
              ),
            ),
            ...shapes.map((shape) {
              if (shape is Circle) {
                return Positioned(
                  left: shape.position.dx - shape.radius,
                  top: shape.position.dy - shape.radius,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: shape.onTap,
                    child: Container(
                      width: shape.radius * 2,
                      height: shape.radius * 2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                );
              } else if (shape is Square) {
                return Positioned(
                  left: shape.position.dx - shape.sideLength / 2,
                  top: shape.position.dy - shape.sideLength / 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: shape.onTap,
                    child: Container(
                      width: shape.sideLength,
                      height: shape.sideLength,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox
                    .shrink(); // Placeholder for other shapes in the future
              }
            }).toList(),
          ],
        ));
  }
}
