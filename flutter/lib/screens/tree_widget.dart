import 'dart:convert';

import 'package:esp_christmas_tree/data/animation.dart';
import 'package:esp_christmas_tree/data/saved_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:http/http.dart' as http;

import '../main_old.dart';
import '../main.dart';
import 'community_widget.dart';

class TreeWidget extends StatefulWidget {
  const TreeWidget({Key? key}) : super(key: key);

  @override
  _TreeWidgetState createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(key.currentState!.loadedFileName),
            ),

            FrameTools(),
            // Frame selection
            FrameSelector(),

            MiscTools(),

            treeRow(0, 1),
            treeRow(1, 2),
            treeRow(3, 2),
            treeRow(5, 1),

            FileTools(),
          ],
        ),
      ),
      padding: const EdgeInsets.all(0.0),
      alignment: Alignment.center,
    );
  }

  /// Generates a row of buttons.
  Widget treeRow(int startIndex, int count) {
    List<Widget> treeButtons = [];
    for (int i = 0; i < count; i++) {
      treeButtons.add(
        ElevatedButton(
          onPressed: () => colorPickerDialog(context, startIndex),
          child: const Text(""),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(key
                .currentState!.animation
                .getFrame(key.currentState!.currentFrame)
                .getColor(startIndex + i)),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: treeButtons,
    );
  }

  var colorSelection = const [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.black
  ];

  void colorPickerDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select new color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: key.currentState!.animation
                  .getFrame(key.currentState!.currentFrame)
                  .getColor(index),
              onColorChanged: (value) {
                setState(() {
                  key.currentState!.animation
                      .getFrame(key.currentState!.currentFrame)
                      .setColor(index, value);
                });
                Navigator.of(context).pop();
              },
              availableColors: colorSelection,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget MiscTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text("Frame: " +
            (key.currentState!.currentFrame + 1).toString() +
            " / " +
            key.currentState!.animation.getTotalFrames().toString()),
        ElevatedButton(
          onPressed: () {
            randomizeTree();
          },
          child: const Text("Randomize"),
        ),
        Text("Time: " +
            (key.currentState!.animation.getTotalFrames() * 0.5).toString() +
            " s"),
      ],
    );
  }

  Widget FrameSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          onPressed: key.currentState!.currentFrame <= 0
              ? null
              : () {
                  setActiveFrame(key.currentState!.currentFrame - 1);
                },
          child: const Icon(Icons.skip_previous),
        ),
        ElevatedButton(
          onPressed:
              key.currentState!.animation.getTotalFrames() == 1 ? null : () {},
          child: const Icon(Icons.slideshow),
        ),
        ElevatedButton(
          onPressed: key.currentState!.currentFrame >=
                  key.currentState!.animation.getTotalFrames() - 1
              ? null
              : () {
                  setActiveFrame(key.currentState!.currentFrame + 1);
                },
          child: const Icon(Icons.skip_next),
        ),
      ],
    );
  }

  Widget FrameTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          onPressed: key.currentState!.animation.getTotalFrames() >= 256
              ? null
              : () {
                  if (key.currentState!.animation.getTotalFrames() >= 256) {
                    return;
                  }

                  setState(() {
                    key.currentState!.animation.addFrame(TreeFrame());
                    setActiveFrame(
                        key.currentState!.animation.getTotalFrames() - 1);
                  });
                },
          child: const Icon(Icons.add),
        ),
        ElevatedButton(
          onPressed: key.currentState!.animation.getTotalFrames() - 1 <= 0
              ? null
              : () {
                  setState(() {
                    var newLength =
                        key.currentState!.animation.removeLastFrame();
                    if (key.currentState!.currentFrame > newLength - 1) {
                      setActiveFrame(
                          key.currentState!.animation.getTotalFrames() - 1);
                    }
                  });
                },
          child: const Icon(Icons.delete),
        ),
        ElevatedButton(
          onPressed: key.currentState!.animation.getTotalFrames() - 1 <= 0
              ? null
              : () {
                  setState(() {
                    key.currentState!.animation = TreeAnimation();
                    setActiveFrame(0);
                  });
                },
          child: const Icon(Icons.delete_forever),
        ),
        ElevatedButton(
          onPressed: key.currentState!.animation.getTotalFrames() >= 256
              ? null
              : () {
                  setState(() {
                    key.currentState!.animation.addFrame(TreeFrame(key
                        .currentState!.animation
                        .getFrame(key.currentState!.currentFrame)
                        .getColors()));
                    setActiveFrame(
                        key.currentState!.animation.getTotalFrames() - 1);
                    randomizeTree();
                  });
                },
          child: const Icon(Icons.ac_unit),
        ),
        ElevatedButton(
          onPressed: key.currentState!.animation.getTotalFrames() >= 256
              ? null
              : () {
                  setState(() {
                    key.currentState!.animation.addFrame(TreeFrame(key
                        .currentState!.animation
                        .getFrame(key.currentState!.currentFrame)
                        .getColors()));
                    setActiveFrame(
                        key.currentState!.animation.getTotalFrames() - 1);
                  });
                },
          child: const Icon(Icons.content_copy),
        ),
      ],
    );
  }

  void setActiveFrame(int idx) {
    setState(() {
      key.currentState!.currentFrame = idx;
    });
  }

  void randomizeTree() {
    for (int i = 0;
        i <
            key.currentState!.animation
                .getFrame(key.currentState!.currentFrame)
                .getColors()
                .length;
        i++) {
      key.currentState!.animation
          .getFrame(key.currentState!.currentFrame)
          .setColorInt(i, next(0, 4));
    }
    setState(() {});
  }

  void uploadDataToEsp() async {
    var ipAddress = key.currentState!.espIp;
    if (ipAddress == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("Please check IP of the ESP"),
      ));
      return;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Please wait..'),
          content: Text("We're uploading the animation to your ESP...."),
        );
      },
    );

    http.Response response;
    try {
      response = await http
          .post(
        Uri.parse("http://" + ipAddress + "/post"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: key.currentState!.animation.toJsonData(),
      )
          .timeout(const Duration(seconds: 5), onTimeout: () {
        return http.Response('Error', 500);
      });
    } catch (_) {
      Navigator.of(context).pop();

      showSimpleDialog("An error occurred", "Timout. Check IP!");
      return;
    }

    // TODO: Saving to mobile phone storage!

    if (response.statusCode != 200) {
      showSimpleDialog("An error occurred", "ESP returned an error.");
      return;
    }

    Map<String, dynamic> result = jsonDecode(response.body);
    if (result["result"] != 0) {
      Navigator.of(context).pop();

      showSimpleDialog("An error occurred", result['msg']);
      return;
    }

    setState(() {
      Navigator.of(context).pop();
    });

    showSimpleSnackbar("Upload successful!");
  }

  void showSimpleSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(message),
    ));
  }

  void showSimpleDialog(String title, String text, [bool dismissable = true]) {
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
  }

  late TextEditingController _controller;

  void onFileSavePressed() {
    if (key.currentState!.loadedFileName != "") {
      saveFile(key.currentState!.loadedFileName);
      return;
    }

    _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Name of Animation'),
          content: SingleChildScrollView(
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "File Name"),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_controller.text == "") {
                  return;
                }
                Navigator.pop(context);
                saveFile(_controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  void onSharePressed() {
    _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Title of Animation'),
          content: SingleChildScrollView(
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "Title"),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_controller.text == "") {
                  return;
                }

                Navigator.pop(context);
                shareFile(_controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  void shareFile(String title) async {
    showSimpleDialog("Sharing", "Sharing Animation...", false);

    var response = await http.post(
      Uri.parse("http://" + key.currentState!.communityUrl + "/api/creations/share"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: "{\"title\": \"" + title + "\","+
          "\"json_data\": " + key.currentState!.animation.toJsonData() + "}",
    );

    if (response.statusCode != 200) {
      showSimpleSnackbar("Request failed.");

      Navigator.of(context).pop();
      return;
    }

    Map<String, dynamic> result = jsonDecode(response.body);
    if (result["result"] != 0) {
      showSimpleSnackbar(result['msg']);

      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Upload succeeded!"),
    ));
    Navigator.of(context).pop();
  }

  void saveFile(String fileName) async {
    showSimpleDialog("Saving", "Saving Animation to file...", false);
    var result = await saveDataToFile(
        fileName, key.currentState!.animation.toJsonData(), true);
    Navigator.pop(context);

    if (result) {
      setState(() {
        key.currentState!.loadedFileName = fileName;
      });
    }

    showSimpleSnackbar(result ? "File saved!" : "File save error.");
  }

  void onFileClosePressed() {
    setState(() {
      key.currentState!.animation = TreeAnimation();
      key.currentState!.currentFrame = 0;
      key.currentState!.loadedFileName = "";
    });
  }

  void onFileDeletePressed() async {
    showSimpleDialog("Deleting..", "Deleting animation file..", false);

    var result = await deleteFile(key.currentState!.loadedFileName);
    Navigator.of(context).pop();
    if (result) {
      onFileClosePressed();
    }
    showSimpleSnackbar(result ? "File deleted!" : "Failed to delete file");
  }

  Widget FileTools() {
    List<Widget> children = [];

    Widget uploadButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
      ),
      onPressed: () {
        setState(() {
          uploadDataToEsp();
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: const [Icon(Icons.upload), Text("Upload")],
      ),
    );

    Widget saveButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
      ),
      onPressed: onFileSavePressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: const [Icon(Icons.save), Text("Save")],
      ),
    );

    Widget shareButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo),
      ),
      onPressed: onSharePressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: const [Icon(Icons.share), Text("Share")],
      ),
    );

    children.add(
      key.currentState!.loadedFileName != ""
          ? Column(
              children: [
                uploadButton,
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.indigo),
                  ),
                  onPressed: onFileDeletePressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: const [Icon(Icons.delete), Text("Delete")],
                  ),
                ),
              ],
            )
          : uploadButton,
    );

    children.add(
      key.currentState!.loadedFileName != ""
          ? Column(children: [
              saveButton,
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.indigo),
                ),
                onPressed: onFileClosePressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: const [Icon(Icons.close), Text("Close")],
                ),
              ),
            ])
          : saveButton,
    );

    children.add(
      key.currentState!.loadedFileName != ""
          ? Column(children: [
              shareButton,
              ElevatedButton(
                onPressed: null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: const [Text("")],
                ),
              ),
            ])
          : shareButton,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: children,
    );
  }
}
