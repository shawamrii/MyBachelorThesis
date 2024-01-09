import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getMyDeviceType() async{
  try{
    if (Platform.isAndroid) {
      return "Android";
    } else if (Platform.isIOS) {
      return "IOS";
    }
    return "Unknown";
  }catch(e){
    return "Unknown";
  }
}
Future<void> saveMeLocally(String filename, String data) async
  {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      if (!(await file.exists())) {
        await file.create(recursive: true);
        debugPrint("File created: $filePath");
      }

      await file.writeAsString(data, mode: FileMode.append);
      debugPrint("Data appended to file at $filePath");
    } catch (e) {
      debugPrint("An error occurred while saving data locally: $e");
    }
  }