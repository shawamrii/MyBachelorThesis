import 'package:flutter/material.dart';

import 'package:lock_tracker/pages/settings.dart';
import 'package:lock_tracker/services/configData.dart';
import 'package:lock_tracker/services/connectivity.dart';
import 'package:lock_tracker/services/json_maker.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ServerConnectivityService()),
        ChangeNotifierProvider(create: (context) => ConfigData()),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> uniqueIdFuture;

  @override
  void initState() {
    super.initState();
    uniqueIdFuture = getFileUniqueId();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final connectivityService = Provider.of<ServerConnectivityService>(context);
    uniqueIdFuture.then((uniqueId) {
      connectivityService.updateFileName("file_$uniqueId.json");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String>(
        future: uniqueIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else if (snapshot.hasData) {
            // The provider is now scoped only to ConfigScreen and its descendants
            return  const ConfigScreen();
          } else {
            return const Scaffold(
              body: Center(
                child: Text('Unexpected error.'),
              ),
            );
          }
        },
      ),
    );
  }
}

