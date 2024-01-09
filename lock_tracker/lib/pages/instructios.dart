// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';
import 'signatureScreen.dart';
import 'bmsSurvey.dart';

class AcceptanceScreen extends StatefulWidget {

  const AcceptanceScreen({
    Key? key,
    // Default text
  }) : super(key: key);

  @override
  State<AcceptanceScreen> createState() => _AcceptanceScreenState();
}

class _AcceptanceScreenState extends State<AcceptanceScreen> {
  final List<Map<String, dynamic>> jsonLogMessages=[];
  final String text="INSTRUCTIONS AND PRIVACY \n Please read and accept the terms to continue.";
  late ConfigData initialConfig;
  @override
  void initState() {
    super.initState();
    Map<String,dynamic> logMessage={
      "Event":"The Privacy Screen starts",
      "Timestamp":DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
  }
  void acceptAndGo(BuildContext context, ServerConnectivityService connectivityService) async {
    // Push the signature screen and wait for the result
    final signatureFilePath = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignatureScreen(
          onSigned: (filePath) {
            // This will be called after the signature is saved
            Navigator.of(context).pop(filePath); // Return the path to the acceptance screen
          },
        ),
      ),
    );

    if (signatureFilePath == "isSigned") {
      // If the signature process was completed
      Map<String,dynamic> logMessage={
        "Event":"The Privacy ends",
        "Timestamp":DateTime.now().toIso8601String(),
      };
      jsonLogMessages.add(logMessage);
      // Navigate to the BmsSurveyWidget
      await sendJsonToServer(jsonLogMessages,"Instrucion",connectivityService);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BmsSurveyWidget(
            index: 1,
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
        title: const Text('Anleitung'),
        automaticallyImplyLeading:false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () => acceptAndGo(context,connectivityService),
              child: const Text('Annehmen'),
            ),
          ],
        ),
      ),
    );
  }
}


