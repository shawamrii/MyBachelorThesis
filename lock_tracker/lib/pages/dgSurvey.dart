// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/closeDialog.dart';
import '../services/configData.dart';
import 'package:lock_tracker/services/json_maker.dart';
import 'package:provider/provider.dart';

import '../services/connectivity.dart';

class DemographicsSurvey extends StatefulWidget {
  const DemographicsSurvey({Key? key}) : super(key: key);

  @override
  _DemographicsSurveyState createState() => _DemographicsSurveyState();
}

class _DemographicsSurveyState extends State<DemographicsSurvey> {
  final _formKey = GlobalKey<FormState>();
  String ageGroup = '18-24'; // Setze einen Standardwert oder einen Platzhalter
  String gender =
      'Männlich/Man'; // Setze einen Standardwert oder einen Platzhalter
  String deviceType =
      'Smartphone IOS'; // Setze einen Standardwert oder einen Platzhalter
  String manualDeviceType = '';
  List<Map<String, dynamic>> jsonLogMessages = [];

  @override
  Widget build(BuildContext context) {
    final connectivityService =
        Provider.of<ServerConnectivityService>(context, listen: false);
    final configData = Provider.of<ConfigData>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(configData.language == Language.EN
            ? 'Demographics Survey'
            : 'Demografie Umfrage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              await showExitConfirmationDialog(context,connectivityService,jsonLogMessages,"Demographics Survey",configData.language);

            },
            tooltip: 'Close',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonFormField(
                  value: ageGroup,
                  onChanged: (String? newValue) {
                    setState(() {
                      ageGroup = newValue!;
                    });
                  },
                  items: <String>[
                    '18-24',
                    '25-34',
                    '35-44',
                    '45-54',
                    '55+',
                    'keine Angabe'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                      labelText: configData.language == Language.DE
                          ? 'Altersgruppe'
                          : "Age group"),
                ),
                DropdownButtonFormField(
                  value: gender,
                  onChanged: (String? newValue) {
                    setState(() {
                      gender = newValue!;
                    });
                  },
                  items: <String>[
                    'Männlich/Man',
                    'Weiblich/Woman',
                    'Weder noch/Not listed here',
                    'Keine Eingabe/I dont want to Answer'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                      labelText: configData.language == Language.DE
                          ? 'Geschlecht'
                          : "Sex"),
                ),
                DropdownButtonFormField(
                  value: deviceType,
                  onChanged: (String? newValue) {
                    setState(() {
                      deviceType = newValue!;
                    });
                  },
                  items: <String>[
                    'Smartphone Andoid',
                    'Smartphone IOS',
                    'Tablet Android',
                    'Tablet IOS',
                    configData.language == Language.DE ? 'Andere' : "Others"
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                      labelText: configData.language == Language.DE
                          ? 'Gerätetyp'
                          : 'Device type'),
                ),
                if (deviceType == 'Andere' || deviceType == 'Others')
                  TextField(
                    onChanged: (String newValue) {
                      manualDeviceType = newValue;
                    },
                    decoration: InputDecoration(
                      labelText: configData.language == Language.DE
                          ? 'Gerätetyp (manuell)'
                          : 'Device type (manual)',
                    ),
                  ),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      String finalDeviceType = (deviceType == 'Andere' || deviceType == 'Others')
                          ? manualDeviceType
                          : deviceType;
                      Map<String, dynamic> logMessage = {
                        'ageGroup': ageGroup,
                        'gender': gender,
                        'deviceType': finalDeviceType,
                        "Timestamp": DateTime.now().toIso8601String(),
                      };
                      jsonLogMessages.add(logMessage);
                      // Daten speichern oder verarbeiten
                      await sendJsonToServer(
                          jsonLogMessages, "Demographic", connectivityService);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Text('Speichern und Zurück'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
