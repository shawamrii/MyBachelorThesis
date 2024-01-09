import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'apiServices/apiService.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}


class MyHomePage extends StatelessWidget {
  final ApiService apiService = ApiService();

  MyHomePage({super.key});
  // This will be called when the edit button is tapped
  Future<void> _displayTextInputDialog(BuildContext context, String originalFileName) async {
    TextEditingController _textFieldController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Content of $originalFileName'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Enter new content here"),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  String newContent = _textFieldController.text;
                  // Call your API service to edit the file here
                  apiService.editFile(originalFileName, newContent);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              try {
                // Trigger the file picker and wait for the user to pick a file
                Uint8List? newFile = await apiService.pickFile();

                if (newFile != null) {
                  // If a file is picked, upload the file
                  await apiService.addFile(newFile,"my_file");
                  // Trigger a state update here, for example:
                  // setState(() {});
                  // If using a more advanced state management solution, trigger the equivalent action.
                } else {
                  if (kDebugMode) {
                    print('No file was selected.');
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print('An error occurred while picking or uploading the file: $e');
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.create),
            onPressed: () async {
              await apiService.createFileOnServer("Hallo World!");
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: apiService.getFiles(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<dynamic> files = snapshot.data ?? [];
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                var file = files[index];
                return ListTile(
                  title: Text(file['filename']),
                  subtitle: Text(file['creation_stamp']??"${DateTime.now()}"),
                  onTap: () async {
                    // Download logic remains the same
                    try {
                      String filename = file['filename'];
                      String content = await apiService.getFileContent(filename);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(filename),
                            content: SingleChildScrollView(
                              child: Text(content),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      // Handle the exception, perhaps show a dialog with the error message
                      print('Error retrieving file content: $e');
                    }

                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _displayTextInputDialog(context, file['filename']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          String filename = file["filename"];
                          apiService.downloadFile(filename);

                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text(
                                    "Are you sure you want to delete this file?"),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text("Delete"),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await apiService.removeFile(
                                          file['filename']);
                                      // Consider adding logic to refresh the file list
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),

                    ],
                  ),
                );

              },
            );
          }
          else {
            return const Center(child: Text('No files found.'));
          }
        },
      ),
    );
  }
}


