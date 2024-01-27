// ignore_for_file: must_be_immutable, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lock_tracker/pages/password.dart';
import 'package:lock_tracker/pages/settings.dart';
import 'package:provider/provider.dart';
import '../services/closeDialog.dart';
import '../services/collision_services.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';
import '../services/shapes.dart';
import 'animation.dart';
import 'bmsSurvey.dart';
import 'passwordDialog.dart';

class AnimationTestingScreen extends StatefulWidget {
  final int aktuelleWiederholung;
  late int testsCounter;

  AnimationTestingScreen(
      {super.key,
      required this.aktuelleWiederholung,
      required this.testsCounter,});

  @override
  _AnimationTestingScreenState createState() => _AnimationTestingScreenState();
}

class _AnimationTestingScreenState extends State<AnimationTestingScreen>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> jsonLogMessages = [];
  late AnimationController _controller;
  late Size screenSize = const Size(200, 300);
  late bool isAnimating = false;
  late bool isStartButtonVisible = true;

  List<Shape> shapes = [];
  late ShapeType shapeType;
  late Color textColor;
  late Color shapeColor;
  late String password;
  bool startAnimation = false;
  late int aktuelleWiederholung;
  late int testsCounter = 1;
  int reloadCounter = 0;
  late ConfigData configData;

  @override
  void initState() {
    super.initState();
    configData = Provider.of<ConfigData>(context, listen: false);
    Map<String, dynamic> logMessage = {
      "Event": "The Test Animation Screen starts",
      "Test Nr.": testsCounter,
      "Reload Nr.": reloadCounter,
      "Round Nr.": widget.aktuelleWiederholung,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        initializeScreen();
      }
    });
  }

  void initializeScreen() {
    setState(() {
      startAnimation = false;
      isAnimating = false;
      screenSize = getScreenSize(context);
      testsCounter = widget.testsCounter;
      isStartButtonVisible = true;
      // Load configurations
      password = configData.password;
      aktuelleWiederholung = widget.aktuelleWiederholung;
        reloadCounter++;
        Map<String, dynamic> logMessage = {
          "Event": "The Test Animation Screen starts",
          "Test Nr.": testsCounter,
          "Reload Nr.": reloadCounter,
          "Round Nr.": widget.aktuelleWiederholung,
          "Timestamp": DateTime.now().toIso8601String(),
        };
        jsonLogMessages.add(logMessage);
      textColor = configData.textColor ?? Colors.white;
      shapeColor = configData.shapeColor ?? Colors.blue;
      shapeType = configData.shapeType;

      shapes = _initializeShapes(
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
                shape.textColor=shapeColor;
                shape.move(screenSize, configData.speed,
                    _controller.value, configData.shapeType);
              }
            });
          }
        });
    });
  }

  Size getScreenSize(BuildContext context) {
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

    return Size(widthWithoutAppBar, heightWithoutAppBar);
  }


  List<Shape> _initializeShapes(
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

  Future<void> _close(context, ServerConnectivityService connectivityService) async {
    if (kDebugMode) {
      debugPrint("_close");
    }
    // Close the animation screen
    Map<String, dynamic> logMessage = {
      "Event": "Close button clicked",
      "Round Nr.": widget.aktuelleWiederholung,
      "Reload Nr.": reloadCounter,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    showExitConfirmationDialog(context,connectivityService,jsonLogMessages,"Test",configData.language);

/*    if (mounted) {
      if (kIsWeb) {
        await sendJsonToServer( jsonLogMessages, "Test",connectivityService);
      } else {
        await sendJsonToServer( jsonLogMessages, "Test",connectivityService);
      }
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const ConfigScreen(

        ),
      ));
    }*/
  }
  Future<void> _skip(ServerConnectivityService connectivityService) async {
    Map<String, dynamic> logMessage = {
      "Event": "Skip The Animation Test Screen",
      "Test Nr.": testsCounter,
      "Reload Nr.": reloadCounter,
      "Round Nr.": widget.aktuelleWiederholung,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    sendJsonToServer( jsonLogMessages, "Test", connectivityService);
    if(mounted) {
      Navigator.of(context).pop(); // Close the dialog
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BmsSurveyWidget(
            index: 1,
            screenSize : screenSize,
          ),
        ),
      );

      /* BMS kommt anstatt
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AnimationScreen(
          aktuelleWiederholung: 1,
          screenSize: screenSize,
        ),
      ));*/
    }
  }

  Future<void> _refresh() async {
    if (kDebugMode) {
      debugPrint("_refresh");
    }
    Map<String, dynamic> logMessage = {
      "Event": "Reload Button clicked",
      "Reload Nr.": reloadCounter,
      "Round Nr.": widget.aktuelleWiederholung,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    setState(() {
      initializeScreen();
    });
  }

  Future<void> _tapDown(TapDownDetails details) async {
    if (kDebugMode) {
      debugPrint("_tapDown ${details.globalPosition}");
    }
    Map<String, dynamic> logMessage = {
      "Event": "Test Animation Screen touched",
      "Test Nr.": testsCounter,
      "Reload Nr.": reloadCounter,
      "Position.": details.globalPosition.toString(),
      "Round Nr.": widget.aktuelleWiederholung,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
  }

  Future<void> _onTap(
      String shape, String id, bool isPin, bool isStartAnimation) async {
    if (kDebugMode) {
      debugPrint("_onTap $id");
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
        await _naechsteWiederholung(connectivityService);
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
      "type": "AnimationTest",
      "Event": "Play button clicked",
      "Round Nr.": widget.aktuelleWiederholung,
      "Reload Nr.": reloadCounter,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    if (mounted) {
      setState(() {
        isAnimating = true;
        isStartButtonVisible = false;
        _controller.forward();
      });
      startAnimation = true;
    }
  }

  void checkEdgeCollisions() {
    if (shapeType == ShapeType.circle) {
      List<Circle> circles =
          shapes.whereType<Circle>().cast<Circle>().toList();
      checkEdgeCollisionsForCircles(circles, screenSize);
    } else if (shapeType == ShapeType.square) {
      List<Square> squares =
          shapes.whereType<Square>().cast<Square>().toList();
      checkEdgeCollisionsForSquares(squares, screenSize);
    } else {
      Future.error("Shape is missing");
    }
  }

  void checkCollisions() {
    if (shapeType == ShapeType.circle) {
      List<Circle> circles =
          shapes.whereType<Circle>().cast<Circle>().toList();
      checkCollisionsForCircles(circles, screenSize);
    } else if (shapeType == ShapeType.square) {
      List<Square> squares =
          shapes.whereType<Square>().cast<Square>().toList();
      checkCollisionsForSquares(squares);
    } else {
      Future.error("Shape is missing");
    }
  }

  Future<void> _naechsteWiederholung(ServerConnectivityService connectivityService) async {
    if (widget.aktuelleWiederholung < configData.maxPasswortLaenge) {
      Map<String, dynamic> logMessage = {
        "Event": "The Test Animation Test ends",
        "Test Nr.": testsCounter,
        "Reload Nr.": reloadCounter,
        "Round Nr.": widget.aktuelleWiederholung,
        "Timestamp": DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AnimationTestingScreen(
            aktuelleWiederholung: widget.aktuelleWiederholung + 1,
            testsCounter: testsCounter,
          ),
        ));
      }
    } else {
      // Ende der Wiederholungen
      Map<String, dynamic> logMessage = {
        "Event": "The Animation Test Game finished",
        "Test Nr.": testsCounter,
        "Reload Nr.": reloadCounter,
        "Round Nr.": widget.aktuelleWiederholung,
        "Timestamp": DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
      if (kIsWeb) {
        await sendJsonToServer( jsonLogMessages, "Test",connectivityService);
      } else {
        await sendJsonToServer(jsonLogMessages, "Test",connectivityService);
      }
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PasswordEndDialog(
                testsCounter: testsCounter,
                screenSize: screenSize,
              )));
    }
  }

  @override
  void dispose() {
    _controller.stop(); // Stop the controller if it's still running
    _controller.dispose(); // This line disposes of the AnimationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    return Scaffold(
        backgroundColor: configData.backgroundColor ?? Colors.white,
        appBar: AppBar(
          title: Text(
              "Stelle ${widget.aktuelleWiederholung} von ${configData.maxPasswortLaenge}- Nr.$reloadCounter"),
          automaticallyImplyLeading: false,
          actions: [
            if (isStartButtonVisible)
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  _play();
                },
                tooltip: 'Start',
              ),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: () async {
                Map<String, dynamic> logMessage = {
                  "Event": "Reload The Animation Test Screen",
                  "Test Nr.": testsCounter,
                  "Reload Nr.": reloadCounter,
                  "Round Nr.": widget.aktuelleWiederholung,
                  "Timestamp": DateTime.now().toIso8601String(),
                };
                jsonLogMessages.add(logMessage);
                if (mounted) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => PasswortEingabeScreen(
                      testsCounter: testsCounter + 1,
                    ),
                  ));
                }
              },
              tooltip: 'Restart',
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_left_outlined),
              onPressed: () async {
                _skip(connectivityService);
              },
              tooltip: 'Skip',
            ),

            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await _close(context,connectivityService);
              },
              tooltip: 'Close',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await _refresh();
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) async {
                  await _tapDown(details);
                },
                child: CustomPaint(
                  painter: ShapePainter(
                      shapes,
                      testsCounter == 1 &&
                          reloadCounter == 1 &&
                          aktuelleWiederholung ==
                              1,
                      configData.lineWidth,screenSize), // Updated to a more generic painter
                ),
              ),
            ),
            ...shapes.map((shape) {
              if (shape is Circle) {
                return Positioned(
                  left: shape.position.dx - shape.radius,
                  top: shape.position.dy - shape.radius,
                  child: GestureDetector(
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
