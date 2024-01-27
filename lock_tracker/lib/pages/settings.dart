// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/configData.dart';
import '../services/connectivity.dart';
import '../services/json_maker.dart';
import '../services/screen_infos.dart';
import 'instructios.dart';
import 'package:http/http.dart' as http;


class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  List<Map<String, dynamic>> jsonLogMessages = [];
  late ServerConnectivityService connectivityService;
  late ConfigData configData;

  @override
  void initState() {
    super.initState();
    fetchJsonData();
    Map<String, dynamic> logMessage = {
      "Event": "Setting Screen starts",
      "Timestamp": DateTime.now().toIso8601String(),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) async => _initAsync());
    jsonLogMessages.add(logMessage);

  }


  @override
  void dispose() {
    // Dispose of the controllers when the state is disposed
    super.dispose();
  }

  Future<void> _initAsync() async {
    if (mounted) {
      Map<String, dynamic> infos =
          await saveInfosAsJson(context, connectivityService.filename);
      jsonLogMessages.add(infos);
    }
  }

  Future<void> saveAndGo(ServerConnectivityService connectivityService,
      ConfigData configData) async {
    jsonLogMessages.add(configData.toJson());

    Map<String, dynamic> logMessage = {
      "Event": "Setting Screen ends",
      "Timestamp": DateTime.now().toIso8601String(),
    };
    jsonLogMessages.add(logMessage);
    if (mounted) {
      await sendJsonToServer(jsonLogMessages, "Setting", connectivityService);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const AcceptanceScreen(),
      ));
    }
  }

  Future<void> fetchJsonData() async {
    String serverUrl = kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";
    final String url = '$serverUrl/getJson';
    final response = await http.get(Uri.parse(url));

    if (connectivityService.isServerOnline) {
      var jsonData = json.decode(response.body);
      configData.updateWithJson(jsonData);  // Pass the jsonData directly
      if (kDebugMode) {
        print(configData.toJson().toString());
      }
    } else {
      throw Exception('Failed to load JSON data from Server');
    }
    configData.updateShapeSize(calculateMaxShapeSize(configData.numberOfShapes));
    print(configData.toJson().toString());
  }

  double calculateMaxShapeSize(int numberOfShapes) {
    if (numberOfShapes <= 10) {
      return configData.shapeSize;
    } else {
      // Here we get the actual screen size from the MediaQuery
      Size actualScreenSize = MediaQuery.of(context).size;

      // Get the height of the status bar
      double statusBarHeight = MediaQuery.of(context).padding.top;

      // Get the height of the AppBar
      double appBarHeight = kToolbarHeight; // default height

      // Calculate the height without the status bar and the AppBar
      double heightWithoutAppBar =
          actualScreenSize.height - statusBarHeight - appBarHeight;

      // Width remains the same
      double widthWithoutAppBar = actualScreenSize.width;
      final int numShapesSide = sqrt(numberOfShapes).ceil();
      // Calculate maximum size for each shape
      final maxShapeWidth = widthWithoutAppBar>numShapesSide? widthWithoutAppBar/numShapesSide : widthWithoutAppBar;
      final maxShapeHeight = heightWithoutAppBar>numShapesSide? heightWithoutAppBar/numShapesSide : heightWithoutAppBar;
      //print("$maxShapeWidth,$maxShapeHeight,$numShapesSide");
      return min(maxShapeWidth / 2, maxShapeHeight / 2).roundToDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    connectivityService = Provider.of<ServerConnectivityService>(context, listen: false);
    configData = Provider.of<ConfigData>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Einstellungen")),
      body: Center(
        child: Consumer<ConfigData>(
          builder: (context, configData, child) {
            return ListView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(20.0),
              children: [
                const Text("Sprache der Umfragen"),
                DropdownButton<Language>(
                  value: configData.language,
                  items: const <DropdownMenuItem<Language>>[
                    DropdownMenuItem(
                      value: Language.EN,
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: Language.DE,
                      child: Text('Deutsch'),
                    ),
                  ],
                  onChanged: (Language? newValue) {
                    configData.updateLanguage(newValue ?? Language.DE);
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    saveAndGo(connectivityService, configData);
                  },
                  child: const Text("Speichern"),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
