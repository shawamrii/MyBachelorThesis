import 'dart:convert';
//import 'dart:html';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lock_tracker/services/screen_infos.dart';
import 'package:path_provider/path_provider.dart';
import 'connectivity.dart';
import 'isWeb.dart';
import 'dart:io';


Future<void> sendJsonToServer(List<Map<String, dynamic>> jsonData, String type,ServerConnectivityService connectivityService) async {
  String filename=connectivityService.filename;
  String? userId = await getDeviceId(filename) ?? "Unknown";
  for (var json in jsonData) {
      json['type'] = type;
      json["User Id"] = userId;
  }
  String url = kIsWeb ? "http://localhost:3000/upload/$filename" : "http://10.0.2.2:3000/upload/$filename";

  if(connectivityService.isServerOnline){
    try {
      String jsonString = jsonEncode(jsonData);
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonString,
      );

      if (response.statusCode == 200) {
        debugPrint("JSON sent and saved successfully to $filename");
      } else {
        debugPrint("Failed to send JSON. Status code: ${response.statusCode}");
        await _saveLocally(
            filename, jsonString); // Save locally if sending fails
      }
    } catch (e) {
      debugPrint("Error occurred: $e");
      await _saveLocally(
          filename, jsonData.toString()); // Save locally if an error occurs
    }
  }
  else{
    debugPrint("Server Is Offline");
    await _saveLocally(
        filename, jsonData.toString()); // Save locally if an error occurs
  }
}

//when connection is off
Future<void> _saveLocally(String filename, String data) async {
  if (kIsWeb) {
    saveMeLocally(filename,data);
  } else {
    // Existing code for mobile or desktop environments
    saveMeLocally(filename, data);
  }
}



// Function to request a unique ID from the server
Future<String> getFileUniqueId() async {
  String url = kIsWeb ? "http://localhost:3000/generate-id" : "http://10.0.2.2:3000/generate-id";
  Duration timeoutDuartion =const Duration(seconds: 3);
    try {
      final response = await http.get(Uri.parse(url)).timeout(timeoutDuartion);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String id = jsonResponse['id'];
        if (kDebugMode) {
          print("Generated ID: $id");
        }
        return id;
      } else {
        throw Exception('Failed to load unique ID from server');
      }
    } catch (e) {
      if (kDebugMode) {
        print("No internet connection or server error: $e");
      }
    }
    return _generateLocalUniqueId();
}

String _generateLocalUniqueId() {
  var rng = Random();
  var formatter = DateFormat('yyyyMMddHHmmss');
  String datePart = formatter.format(DateTime.now());
  String randomPart = rng.nextInt(999999).toString().padLeft(6, '0');
  String localId = 'local_$datePart$randomPart';
  if (kDebugMode) {
    print("Generated local ID: $localId");
  }
  return localId;
}
// Method to delete (remove) a file
Future<void> removeFile(ServerConnectivityService connectivityService) async {
  String filename = connectivityService.filename;
  if(connectivityService.isServerOnline){
    const String baseUrl =
        kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";
    final response = await http.delete(Uri.parse('$baseUrl/remove/$filename'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete file: ${response.statusCode}');
    }
  }else{
    try {
      final directory = await getApplicationDocumentsDirectory(); // Use path_provider to find the local path
      final file = File('${directory.path}/$filename');

      if (await file.exists()) {
        await file.delete();
        print("File deleted: $filename");
      } else {
        print("File not found: $filename");
      }
    } catch (e) {
      print("Error deleting file from storage: $e");
    }
  }
}

