import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/data.json');
}

Future<File> writeJsonToFile(Map<String, dynamic> jsonMap) async {
  final file = await _localFile;
  String jsonString = jsonEncode(jsonMap);
  return file.writeAsString(jsonString);
}

Future<Map<String, dynamic>?> readJsonFromFile() async {
  try {
    final file = await _localFile;
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap;
  } catch (e) {
    print("Error reading JSON from file: $e");
    return null;
  }
}
void deleteJsonFile() async {
  final file = await _localFile;

  if (await file.exists()) {
    await file.delete();
    print('File deleted successfully.');
  } else {
    print('File not found, nothing to delete.');
  }
}