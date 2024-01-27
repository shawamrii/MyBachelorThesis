// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lock_tracker/pages/susSurvey.dart';
import 'package:provider/provider.dart';
import '../services/bmsData.dart';
import '../services/closeDialog.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';
import 'animation.dart';

class BmsSurveyWidget extends StatefulWidget {
  final int index;
  final Size screenSize;

  const BmsSurveyWidget(
      {Key? key,
      required this.index, required this.screenSize,})
      : super(key: key);

  @override
  _BmsSurveyWidgetState createState() => _BmsSurveyWidgetState();
}

class _BmsSurveyWidgetState extends State<BmsSurveyWidget> {
  late List<BmsQuestion> bmsQuestions = [];
  final List<Map<String, dynamic>> jsonLogMessages = [];
  late ConfigData configData;

  @override
  void initState() {
    super.initState();
    configData = Provider.of<ConfigData>(context, listen: false);
    Map<String, dynamic> logMessage = {
      "Event": "BMS Survey Nr. ${widget.index} starts",
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    bmsQuestions =
        BmsSurvey().initializeQuestions(configData.language);
  }

  void saveAndGoToNextPage(ServerConnectivityService connectivityService) async {
    Map<String, dynamic> logMessage = {
      "Event": "BMS Survey Nr. ${widget.index} ends",
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    await sendJsonToServer(
         jsonLogMessages, "BMS ${widget.index}",connectivityService);

    if (widget.index == 1) {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AnimationScreen(
            aktuelleWiederholung: 1,
            screenSize: widget.screenSize,
          ),
        ));

      }
    } else if (widget.index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SusSurveyWidget(
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    final List<String> sliderLabels = configData.language==Language.DE ? [
      'Stimmt gar nicht zu',       // 1
      'Stimmt größtenteils nicht zu', // 2
      'Stimmt eher nicht zu',      // 3
      'Neutral',                   // 4
      'Stimmt etwas zu',           // 5
      'Stimmt größtenteils zu',    // 6
      'Stimmt vollkommen zu'       // 7
    ] : [
      'Strongly Disagree',    // 1
      'Disagree',             // 2
      'Somewhat Disagree',    // 3
      'Neutral',              // 4
      'Somewhat Agree',       // 5
      'Agree',                // 6
      'Strongly Agree'        // 7
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('BMS ${widget.index}: ${configData.language==Language.DE ?'Inwieweit stimmen Sie den folgenden Aussagen zu?' :"To what extent do you agree with the following statements"}'),
        automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await showExitConfirmationDialog(context,connectivityService,jsonLogMessages,"BMS ${widget.index}",configData.language);

              },
              tooltip: 'Close',
            ),
          ],
      ),
      body: ListView.builder(
        itemCount: bmsQuestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bmsQuestions[index].question),
            subtitle: Slider(
              min: 1,
              max: 7,
              divisions: 6,
              value: (bmsQuestions[index].answer).toDouble(),
              label: sliderLabels[bmsQuestions[index].answer - 1],
              onChanged: (double value) {//we have to save every change on the scale
                setState(() {
                  bmsQuestions[index].answer = value.toInt();
                });
                  Map<String, dynamic> logMessage = {
                    "BMS(${widget.index}) Question": bmsQuestions[index].question,
                    "BMS(${widget.index}) Answer": bmsQuestions[index].answer,
                    "Timestamp": DateTime.now().toIso8601String(),
                  };
                  jsonLogMessages.add(logMessage);
              },
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            saveAndGoToNextPage(connectivityService);
          },
          child: const Text("Speichern"),
        ),
      ),
    );
  }
}
