// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:lock_tracker/pages/testing.dart';
import 'package:provider/provider.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';

class PasswortEingabeScreen extends StatefulWidget {
  late int testsCounter;

  PasswortEingabeScreen(
      {Key? key,
      required this.testsCounter,
      })
      : super(key: key);

  @override
  _PasswortEingabeScreenState createState() => _PasswortEingabeScreenState();
}

class _PasswortEingabeScreenState extends State<PasswortEingabeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _passwortController = TextEditingController();
  late final int maxPasswortLaenge;
  final List<Map<String, dynamic>> jsonLogMessages = [];
  late ConfigData configData;

  @override
  void initState() {
    super.initState();
    configData = Provider.of<ConfigData>(context, listen: false);

    Map<String, dynamic> logMessage = {
      "Event": "Password Screen starts",
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);

    maxPasswortLaenge = configData.maxPasswortLaenge;
  }

  @override
  void dispose() {
    _passwortController.dispose();
    super.dispose();
  }

  Future<void> _geheZumNaechstenBildschirm(ServerConnectivityService connectivityService, ConfigData configData) async {
    if (_passwortController.text.length == maxPasswortLaenge &&
        _formKey.currentState!.validate()) {
      configData.updatePassword(_passwortController.text);
/*      if (mounted) {
        setState(() {
          widget.initialConfig.password = _passwortController.text;
        });
      }*/

      jsonLogMessages.add({
        "type": "Password Info",
        "password_length": maxPasswortLaenge,
        "password": _passwortController.text,
      });
      jsonLogMessages.add({
        "type": "Event",
        "description": "Password Screen ends",
        "timestamp": DateTime.now().toIso8601String(),
      });
      Map<String, dynamic> logMessage = {
        "Event": "Password Screen ends",
        "Timestamp": DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
      await sendJsonToServer( jsonLogMessages, "Password",connectivityService);

      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AnimationTestingScreen(
            aktuelleWiederholung: 1,
            testsCounter: widget.testsCounter,
          ),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Passwort muss genau $maxPasswortLaenge Zeichen lang sein')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    final configData = Provider.of<ConfigData>(context);
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Passwort Eingabe'),
      ),*/
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _passwortController,
                maxLength: maxPasswortLaenge,
                decoration: const InputDecoration(
                  labelText: 'Passwort',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length != maxPasswortLaenge) {
                    return 'Passwort muss genau $maxPasswortLaenge Zeichen lang sein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:() =>  _geheZumNaechstenBildschirm(connectivityService,configData),
                child: const Text('Weiter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
