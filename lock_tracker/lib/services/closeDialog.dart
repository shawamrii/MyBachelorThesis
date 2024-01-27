import 'package:flutter/material.dart';
import '../pages/settings.dart';
import 'configData.dart';
import 'connectivity.dart';
import 'json_maker.dart';

Future<bool?> showExitConfirmationDialog(BuildContext context,ServerConnectivityService connectivityService,List<Map<String, dynamic>> jsonLogMessages,String widgetName,Language ln) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ln==Language.EN?'Confirm Exit':"Abbrechen"),
          content: Text(ln == Language.EN ? 'Do you want to keep or remove your data?' : 'Möchten Sie Ihre Daten behalten oder löschen?'),
          actions: <Widget>[
            TextButton(
              child: Text(ln==Language.EN? 'Keep My Data':'Daten behaletn'),
              onPressed: () async {
                sendJsonToServer(jsonLogMessages,widgetName,connectivityService);
                await Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const ConfigScreen(
                  ),
                ));
              },
            ),
            TextButton(
              child: Text(ln==Language.EN?'Remove My Data':'Daten Löschen'),
              onPressed: () async {
                removeFile(connectivityService);
                await Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const ConfigScreen(
                  ),
                ));              },
            ),
          ],
        );
      },
    );
  }

