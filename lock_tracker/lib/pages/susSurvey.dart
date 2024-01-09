// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';
import '../services/susData.dart';
import 'dgSurvey.dart';


class SusSurveyWidget extends StatefulWidget {

  const SusSurveyWidget({Key? key}) : super(key: key);

  @override
  _SusSurveyWidgetState createState() => _SusSurveyWidgetState();
}

class _SusSurveyWidgetState extends State<SusSurveyWidget> {
  late List<SusQuestion> susQuestions;
  final List<Map<String, dynamic>> jsonLogMessages=[];
  late ConfigData configData;


  @override
  void initState() {
    super.initState();
    configData = Provider.of<ConfigData>(context, listen: false);
    Map<String,dynamic> logMessage={
      "Event":"SUS Survey starts",
      "Timestamp":DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    susQuestions = SusSurvey().initialize(configData.language);
  }

  void saveAndGoToNextPage(ServerConnectivityService connectivityService) async{
    for (SusQuestion sus in susQuestions) {
      Map<String, dynamic> logMessage = {
        "SUS Question": sus.question,
        "SUS Answer": sus.answer,
        "Timestamp": DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
    }
    Map<String,dynamic> logMessage={
      "Event":"SUS Survey ends",
      "Timestamp":DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);

    if(mounted) {
      await sendJsonToServer(jsonLogMessages,"SUS",connectivityService);
      setState(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const DemographicsSurvey(
            ),
          ),
        );

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SUS Umfrage'),
        automaticallyImplyLeading:false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: susQuestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(susQuestions[index].question),
                  subtitle: Slider(
                    value: susQuestions[index].answer.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: susQuestions[index].answer.toString(),
                    onChanged: (double value) {
                      setState(() {
                        susQuestions[index].answer = value.toInt();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                saveAndGoToNextPage(connectivityService);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 36), // double.infinity is the width and 36 is the height
              ),
              child: const Text('weiter'),
            ),
          ),
        ],
      ),
    );
  }
}