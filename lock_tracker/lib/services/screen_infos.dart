// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info/device_info.dart';
import 'isWeb.dart';


Future<String?> getDeviceId(String filename) async {
  if (kIsWeb) {
    // Handling for web
    return 'Web-${filename.replaceFirst("file_", "").replaceFirst("local_", "")}';
  }else {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.androidId; // unique ID on Android
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // unique ID on iOS
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get platform version: $e');
      }
      return "Unknown";
    }
    return "Unknown";
  }
}

Future<String> getDeviceType() async{
  if(kIsWeb){
    return await getMyDeviceType();
  }else {
    return await getMyDeviceType();
  }
}


String generateSessionId() {
  var uuid = const Uuid();
  return uuid.v4(); // generates a random version 4 UUID
}

Future<Size> getScreenResolution(context) async{
  var size = MediaQuery.of(context).size; // Gets logical size in device-independent pixels
  return size;
}

Future<String> getScreenOrientation(BuildContext context) async{
  return MediaQuery.of(context).orientation.toString().split('.').last;
}



Future<Map<String, dynamic>> saveInfosAsJson(BuildContext context,String filename) async {
  try {
    final deviceId =  await getDeviceId(filename);
    final sessionId = generateSessionId();
    final deviceType = await getDeviceType();
    final screenResolution = await getScreenResolution(context);
    final orientation = await getScreenOrientation(context);
    double? brightness;
    AccelerometerEvent? accelerometerData;
    if(!kIsWeb) {
        accelerometerData = await accelerometerEvents.first;
        final screenBrightness = ScreenBrightness();
        brightness = await screenBrightness.current;
    }
    WidgetsFlutterBinding.ensureInitialized();
    // Write the data to the josn Object
    Map<String, dynamic> infoMap = {
      "Event":"Device Infos",
      'Device ID': deviceId,
      'Session ID': sessionId,
      'Device Type': deviceType,
      'Screen Resolution': '${screenResolution.width}x${screenResolution.height}',
      'Orientation': orientation,
      'Accelerometer Data': !kIsWeb ? {
        'X': accelerometerData?.x,
        'Y': accelerometerData?.y,
        'Z': accelerometerData?.z
      } : "Not available on web",
      'Screen Brightness': brightness?.toStringAsFixed(2)??"${MediaQuery.of(context).platformBrightness}".replaceFirst("Brightness.",""),
      "Timestamp":DateTime.now().toIso8601String(),
    };
    return infoMap;
  }catch(e){
    return {
      "Event":"Device Infos",
      "error": "An error occurred",
      "details": e.toString(),
      "Timestamp":DateTime.now().toIso8601String(),
    };
  }
}







