// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lock_tracker/services/configData.dart';
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
  String gender = 'Männlich/Man'; // Setze einen Standardwert oder einen Platzhalter
  String deviceType = 'iPhone'; // Setze einen Standardwert oder einen Platzhalter
  String unlockDuration = '';

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    final configData = Provider.of<ConfigData>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
        title: Text(configData.language==Language.EN?'Demographics Survey':'Demografie Umfrage'),
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
            items: <String>['18-24', '25-34', '35-44', '45-54', '55+']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(labelText: configData.language==Language.DE?'Altersgruppe':"Age group"),
          ),
          DropdownButtonFormField(
            value: gender,
            onChanged: (String? newValue) {
              setState(() {
                gender = newValue!;
              });
            },
            items:<String>['Männlich/Man','Weiblich/Woman','Weder noch/Not listed here','Keine Eingabe/I dont want to Answer']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(labelText: configData.language==Language.DE?'Geschlecht':"Sex"),
          ),
          TextFormField(
            decoration: InputDecoration(labelText: configData.language==Language.DE?'Dauer des Entsperrens':"Time Of Unlocking"),
            onSaved: (value) => unlockDuration = value ?? '',
          ),
          DropdownButtonFormField(
            value: deviceType,
            onChanged: (String? newValue) {
              setState(() {
                deviceType = newValue!;
              });
            },
            items: <String>['iPhone', 'Samsung', 'Andere']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: InputDecoration(labelText: configData.language==Language.DE?'Gerätetyp':'Device type'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Map<String, dynamic> logMessage ={
                  'ageGroup': ageGroup,
                  'gender': gender,
                  'unlockDuration': unlockDuration,
                  'deviceType': deviceType,
                };
                List<Map<String, dynamic>> jsonLogMessages = [];
                jsonLogMessages.add(logMessage);
                // Daten speichern oder verarbeiten
                await sendJsonToServer(jsonLogMessages, "Demographic", connectivityService);
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
