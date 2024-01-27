import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;


class ApiService {
  final String baseUrl = "http://localhost:3000"; // Use your server's IP for a real device
  // Method to send JSON data to the server
  Future<void> sendJsonToServer(Map<String, dynamic> data) async {
    var uri = Uri.parse('$baseUrl/sendJson'); // Update with your endpoint URL

    try {
      var response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
        throw Exception('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
      throw Exception('Error sending data: $e');
    }
  }


  Future<List<dynamic>> getFiles() async {
    final response = await http.get(Uri.parse('$baseUrl/files'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Consider using a more descriptive error message here based on the response status code
      throw Exception('Failed to load files: ${response.statusCode}');
    }
  }
  //pick file

  Future<Uint8List?> pickFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    await uploadInput.onChange.first;
    if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;
      return reader.result as Uint8List?;
    } else {
      // User canceled the picker
      return null;
    }
  }

// Method to upload (add) a file

  Future<void> addFile(dynamic file, String filename) async {
    var uri = Uri.parse('$baseUrl/upload');
    var request = http.MultipartRequest('POST', uri);

    if (kIsWeb) {
      // Web platform - file is Uint8List
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file as Uint8List,
        filename: filename,
      ));
    } else {
      // Mobile platform - file is File
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        (file as File).path,
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      // Handle success
      if (kDebugMode) {
        print('File uploaded successfully: $filename');
      } // For debug purposes
    } else {
      // Log or display the response body for more details
      if (kDebugMode) {
        print('Failed to upload file: ${response.statusCode}');
      }
      throw Exception('Failed to upload file: ${response.statusCode}');
    }
  }


  // Method to delete (remove) a file
  Future<void> removeFile(String filename) async {
    final response = await http.delete(Uri.parse('$baseUrl/remove/$filename'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete file: ${response.statusCode}');
    }
  }

  // Method to update (edit) a file's content
  Future<void> editFile(String originalFileName, String newContent) async {
    final response = await http.put(
      Uri.parse('$baseUrl/edit/$originalFileName'), // Include the filename in the URL
      body: json.encode({
        'newContent': newContent, // Match the key with server side
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Handle success
    } else {
      // Handle failure
      throw Exception('Failed to edit file: ${response.statusCode}');
    }
  }
  // Method to create a file on the server
  Future<bool> createFileOnServer(String content) async {
    // Replace with your actual server endpoint that handles file creation
    final Uri createFileUri = Uri.parse('$baseUrl/create');
    try {
      final response = await http.post(
        createFileUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        // Assuming the server returns a JSON object with a 'message' field on success
        final result = jsonDecode(response.body);
        print(result['message']);
        return true; // Indicating success
      } else {
        // Handle server response error
        print('Failed to create file on server. Status code: ${response.statusCode}');
        return false; // Indicating failure
      }
    } catch (e) {
      // Handle network error
      print('Error creating file on server: $e');
      return false; // Indicating failure
    }
  }
  Future<String> getFileContent(String filename) async {
    final response = await http.get(Uri.parse('$baseUrl/file-content/$filename'));

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get file content: ${response.statusCode}');
    }
  }

  void downloadFile(String filename) async {
    if (kIsWeb) {
      // Web: Create an anchor tag for downloading the file
      final anchor = html.AnchorElement(href: "$baseUrl/uploads/$filename")
        ..setAttribute("download", filename)
        ..click();
    } else {
      // Mobile: Download and save the file locally
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$filename';
        final response = await http.get(Uri.parse("$baseUrl/uploads/$filename"));

        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          print('File downloaded to $filePath');
        } else {
          print('Failed to download file: Server responded with status code ${response.statusCode}');
        }
      } catch (e) {
        print('Error downloading file: $e');
      }
    }
  }


// Other methods to interact with the server can be added here
}



