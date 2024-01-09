// ignore_for_file: must_be_immutable, file_names


import 'package:flutter/material.dart';
import 'package:lock_tracker/pages/testing.dart';
import 'package:lock_tracker/services/json_maker.dart';
import 'package:provider/provider.dart';
import '../services/connectivity.dart';
import 'animation.dart';


class PasswordEndDialog extends StatefulWidget {
  late int testsCounter;
  final Size screenSize;
  PasswordEndDialog({super.key,required this.testsCounter, required this.screenSize,});

  @override
  State<PasswordEndDialog> createState() => _PasswordEndDialogState();
}

class _PasswordEndDialogState extends State<PasswordEndDialog> {
  final List<Map<String, dynamic>> jsonLogMessages=[];
  @override
  void initState() {
    super.initState();
    Map<String,dynamic> logMessage={
      "Event":"After Testing Dialog starts",
      "Timestamp":DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      title: const Text('Password ist richtig!',textAlign: TextAlign.center,),
      content: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              Map<String,dynamic> logMessage={
                "Event":"Reload AnimationsTest Screen game",
                "Game Nr.":widget.testsCounter,
                "Timestamp":DateTime.now().toIso8601String(),
              };
              jsonLogMessages.add(logMessage);
              final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
              sendJsonToServer(jsonLogMessages, "TestScreen", connectivityService);
              // Reload the page
              if(mounted) {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AnimationTestingScreen(
                          aktuelleWiederholung: 1,
                          testsCounter: widget.testsCounter + 1,
                          ),
                ));
              }
            },
            child: const Text('Seite neuladen'),
          ),
          const SizedBox(width: 20,),
          ElevatedButton(
            onPressed: () async {
              Map<String,dynamic> logMessage={
                "Event":"After AnimationsTest Screen game finished",
                "Game Nr.":widget.testsCounter,
                "Timestamp":DateTime.now().toIso8601String(),
              };
              jsonLogMessages.add(logMessage);
              // Navigate to another page
              if(mounted) {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AnimationScreen(
                        aktuelleWiederholung: 1,
                        screenSize: widget.screenSize,

                      ),
                    ));
              }
            },
            child: const Text('Weiter'),
          ),
        ],
      ),
    );
  }
}
