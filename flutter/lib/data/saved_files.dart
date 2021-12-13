import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';

Future<bool> deleteFile(String fileName) async {
  final directory = await getExternalStorageDirectory();
  if (directory == null) return false;

  final path = io.File(directory.path + '/$fileName.json');
  final fileExists = await path.exists();
  if (!fileExists) {
    return false;
  }

  try {
    await path.delete();
  } catch (_) {
    return false;
  }
  return true;
}

Future<bool> saveDataToFile(String fileName, String data,
    [bool overwrite = false]) async {
  final directory = await getExternalStorageDirectory();
  if (directory == null) return false;

  final path = io.File(directory.path + '/$fileName.json');
  final fileExists = await path.exists();
  if (fileExists && !overwrite) {
    return false;
  }

  await path.writeAsString(data);

  return true;
}

Future<String?> readDataFromFile(String fileName) async {
  try {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return null;

    final path = io.File(directory.path + '/$fileName.json');
    final fileExists = await path.exists();
    if (!fileExists) {
      return null;
    }

    // Read the file
    final contents = await path.readAsString();

    return contents;
  } catch (e) {
    // If encountering an error, return 0
    return null;
  }
}

Future<List<String>?> getAllFiles() async {
  final directory = await getExternalStorageDirectory();
  if (directory == null) return null;
  var directoryFiles = directory.listSync();

  List<String> files = [];
  for (var file in directoryFiles) {
    files.add(file.path);
  }
  return files;
}
