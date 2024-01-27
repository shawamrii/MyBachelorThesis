import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'configData.dart';
class ServerConnectivityService with ChangeNotifier {
  bool _isServerOnline = false;
  late String filename;
  final String _serverUrl = kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";

  bool get isServerOnline => _isServerOnline;

  ServerConnectivityService() {
    checkServerConnectivity();
  }

  Future<void> checkServerConnectivity() async {
    try {
      var response = await http.get(Uri.parse(_serverUrl)).timeout(const Duration(seconds: 3));
      _isServerOnline = response.statusCode == 200;
    } catch (e) {
      _isServerOnline = false;
    }
    notifyListeners();
  }

  void updateFileName(String name) {
    filename = name;
    notifyListeners();
  }




}
