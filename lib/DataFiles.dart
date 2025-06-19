import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum fileType{
  serverConfig,
  userInfo,
  generalConfig
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> _localFile(fileType type) async {
  final path = await _localPath;
  String file = '';
  if(type == fileType.serverConfig)
    file = 'serverConfig.json';
  if(type == fileType.userInfo)
    file = 'userInfo.json';
  if(type == fileType.generalConfig)
    file = 'generalConfig.json';

  return File('$path/$file');
}

Future<File> writeJsonToFile(Map<String, dynamic> jsonMap,fileType type) async {
  final file = await _localFile(type);
  String jsonString = jsonEncode(jsonMap);
  return file.writeAsString(jsonString);
}

Future<Map<String, dynamic>?> readJsonFromFile(fileType type) async {
  try {
    final file = await _localFile(type);
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return jsonMap;
  } catch (e) {
    print("Error reading JSON from file: $e");
    return null;
  }
}
void deleteJsonFile(fileType type) async {
  final file = await _localFile(type);

  if (await file.exists()) {
    await file.delete();
    print('File deleted successfully.');
  } else {
    print('File not found, nothing to delete.');
  }
}
