// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lock_tracker/pages/password.dart';
import 'package:lock_tracker/pages/susSurvey.dart';
import 'package:provider/provider.dart';
import '../services/bmsData.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';

class BmsSurveyWidget extends StatefulWidget {
  final int index;

  const BmsSurveyWidget(
      {Key? key,
      required this.index,})
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
    for (var bmsQuestion in bmsQuestions) {
      Map<String, dynamic> logMessage = {
        "BMS(${widget.index}) Question": bmsQuestion.question,
        "BMS(${widget.index}) Answer": bmsQuestion.answer,
        "Timestamp": DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
    }
    Map<String, dynamic> logMessage = {
      "Event": "BMS Survey Nr. ${widget.index} ends",
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    await sendJsonToServer(
         jsonLogMessages, "BMS ${widget.index}",connectivityService);

    if (widget.index == 1) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswortEingabeScreen(
              testsCounter: 1,
            ),
          ),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('BMS Umfrage(${widget.index})'),
        automaticallyImplyLeading: false,
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
              label: bmsQuestions[index].answer.toString(),
              onChanged: (double value) {
                setState(() {
                  bmsQuestions[index].answer = value.toInt();
                });
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
