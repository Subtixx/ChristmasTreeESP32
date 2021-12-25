import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class Utils {
  static void showSimpleSnackbar(BuildContext context, String message,
      [int timeoutSeconds = 1]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: timeoutSeconds),
      content: Text(message),
    ));
  }

  static void showSimpleListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.minPositive,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  title: const Text("Rename"),
                  leading: const Icon(Icons.save),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text("Delete"),
                  leading: const Icon(Icons.delete),
                  onTap: () {},
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<String> showSimpleInputDialog(
      BuildContext context, TextEditingController textEditingController, String title) async {
    String result = "";
    bool dialogResult = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: TextField(
              controller: textEditingController,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  dialogResult = true;

                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    if (dialogResult) {
      result = textEditingController.text;
    }
    textEditingController.text = "";

    return result;
  }

  static Future<bool> showSimpleConfirmDialog(
      BuildContext context, String title) async {
    bool result = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  result = true;

                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );

    return result;
  }

  static void showSimpleDialog(BuildContext context, String title, String text,
      [bool dismissable = true]) {
    if (dismissable) {
      showDialog(
        context: context,
        barrierDismissible: dismissable,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: dismissable,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(title),
              content: Text(text),
            ),
          );
        },
      );
    }
  }

  static void showLoadingDialog(BuildContext context, [String message = ""]) {
    if (message.isEmpty) {
      message = "Loading...";
    } else if (message.length > 20) {
      message = message.substring(0, 20) + "...";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Container(
                    margin: const EdgeInsets.only(left: 7),
                    child: Text(message)),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showErrorDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showErrorSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 25),
      content: Text(title),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }

  static Future<bool> saveDataToFile(String fileName, String data,
      [bool overwrite = false]) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return false;

    final path = io.File(directory.path + '/$fileName');
    final fileExists = await path.exists();
    if (fileExists && !overwrite) {
      return false;
    }

    await path.writeAsString(data);

    return true;
  }

  static Future<String?> readDataFromFile(String fileName) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final path = io.File(directory.path + '/$fileName');
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

  static Future<List<String>?> getAllFiles() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return null;
    var directoryFiles = directory.listSync();

    List<String> files = [];
    for (var file in directoryFiles) {
      files.add(file.path);
    }
    return files;
  }

  static Future<bool> deleteFile(String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return false;

    final path = io.File(directory.path + '/$fileName');
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
}
