// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lock_tracker/services/json_maker.dart';
import 'package:provider/provider.dart';

import '../services/closeDialog.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import 'dgSurvey.dart';

class TimeSurvey extends StatefulWidget {
  const TimeSurvey({Key? key}) : super(key: key);

  @override
  _TimeSurveyState createState() => _TimeSurveyState();
}

class _TimeSurveyState extends State<TimeSurvey> {
  final _formKey = GlobalKey<FormState>();
  String unlockDuration = '';
  List<Map<String, dynamic>> jsonLogMessages = [];

  @override
  Widget build(BuildContext context) {
    final connectivityService =
        Provider.of<ServerConnectivityService>(context, listen: false);
    final configData = Provider.of<ConfigData>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(configData.language == Language.EN
            ? 'Perceived Duration of the Experiment'
            : 'Empfundene Experimentdauer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await showExitConfirmationDialog(context, connectivityService,
                  jsonLogMessages, "Time", Language.EN);
            },
            tooltip: 'Close',
          ),
        ],
      ),
        body: SingleChildScrollView(
        child: ConstrainedBox(
        constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
    ),
    child: IntrinsicHeight(
    child: Center(
    child: Form(
    key: _formKey,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(configData.language == Language.DE
            ? 'Welche Dauer haben Sie für das Experiment empfunden?'
            : 'What was your perceived duration of the experiment?'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding here
          child: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: configData.language == Language.DE ? 'in Sekunden' : "In seconds",
            ),
            onSaved: (value) => unlockDuration = value ?? '',
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Map<String, dynamic> logMessage = {
                'unlockDuration': unlockDuration,
                "Timestamp": DateTime.now().toIso8601String(),
              };
              jsonLogMessages.add(logMessage);
              // Save or process data
              await sendJsonToServer(
                  jsonLogMessages,
                  "Perceived Duration of the Experiment",
                  connectivityService);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DemographicsSurvey(),
                ),
              );
            }
          },
          child: const Text('Weiter'),
        ),
      ],
    )

    ),
        ),
      ),
    ),
    ));
  }
}
