//{
//Nooooooooot working becouse of premissions
//   Future<void> uploadFile() async {
//     if (!await checkStoragePermission()) {
//       print('Storage permission not granted. Cannot upload file.');
//       return;
//     }
//
//     try {
//       final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
//       request.files.add(await http.MultipartFile.fromPath('file', _file.path));
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         print('File uploaded successfully: ${response.body}');
//       } else {
//         print('File upload failed with status: ${response.statusCode}.');
//       }
//     } catch (e) {
//       print('An error occurred during file upload: $e');
//     }
//   }
//
//
//
// }
// ignore_for_file: unused_field
//when connection is off
import 'dart:html' as html;
import 'package:flutter/cupertino.dart';

Future<void> saveMeLocally(String filename, String data) async {

    // Use Local Storage in case of a web app
    try {
      html.window.localStorage[filename] = data;
      debugPrint("Data saved to local storage with key $filename");
    } catch (e) {
      debugPrint("An error occurred while saving data to local storage: $e");
    }
}
Future<String> getMyDeviceType() async{
  try{
    String userAgent = html.window.navigator.userAgent;
    bool isAndroid = userAgent.contains("Android");
    bool isIOS = userAgent.contains("iPhone") || userAgent.contains("iPad");
    if (isAndroid) {
      return "Android";
    }
    if (isIOS) {
      return "IOS";
    }
    return "Web Unknow";
  }catch(e){
    return "Web Unknow";
  }
}

