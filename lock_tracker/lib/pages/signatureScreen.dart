// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lock_tracker/services/configData.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

import '../services/closeDialog.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';

class SignatureScreen extends StatefulWidget {
  final Function(String) onSigned; // Callback function to notify when signature is done

  const SignatureScreen({Key? key, required this.onSigned}) : super(key: key);

  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final List<Map<String, dynamic>> jsonLogMessages=[];
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
  );
  @override
  initState(){
    super.initState();
    Map<String,dynamic> logMessage={
      "Event":"The Signature Screen starts",
      "Timestamp":DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
  }



  Future<void> saveSignatureAsText(Uint8List signatureData, ServerConnectivityService connectivityService) async {
    final String base64String = base64Encode(signatureData);
    Map<String,dynamic> logMessage={
      "Event":"User Signature",
      "Signature":base64String,
      "Timestamp":DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    await sendJsonToServer(jsonLogMessages,"Signature",connectivityService);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unterschreiben'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await showExitConfirmationDialog(context,connectivityService,jsonLogMessages,"Signature",Language.EN);
          },
          tooltip: 'Close',
        ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2), // Border color and width
              color: Colors.white,
            ),
            child: Signature(
              controller: _controller,
              height: 300,
              backgroundColor: Colors.white,

            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text('Speichern & Weiter'),
                onPressed: () async {
                  if (_controller.isNotEmpty) {
                    final signatureData = await _controller.toPngBytes();
                    if (signatureData != null) {
                      final signature = await saveSignatureAsText(signatureData,connectivityService);
                      widget.onSigned("isSigned"); // Callback to the AcceptanceScreen
                    }
                  }
                },
              ),
              ElevatedButton(
                child: const Text('Zurücksetzen'),
                onPressed: () => _controller.clear(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
