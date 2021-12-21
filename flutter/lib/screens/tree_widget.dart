import 'dart:convert';

import 'package:esp_christmas_tree/data/animation.dart';
import 'package:esp_christmas_tree/data/saved_files.dart';
import 'package:esp_christmas_tree/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:http/http.dart' as http;

import '../main_old.dart';
import '../main.dart';

class TreeWidget extends StatefulWidget {
  const TreeWidget({Key? key}) : super(key: key);

  @override
  _TreeWidgetState createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget> {
  TextEditingController? _controller;

  @override
  void dispose() {
    super.dispose();

    if(_controller != null) {
      _controller!.dispose();
    }
  }

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

            frameTools(),
            // Frame selection
            frameSelector(),

            miscTools(),

            paintTools(),

            treeRow(0, 1),
            treeRow(1, 2),
            treeRow(3, 2),
            treeRow(5, 1),

            fileTools(),
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
          onPressed: () => colorPickerDialog(context, (Color selectedColor) {
            setState(() {
              key.currentState!.animation
                  .getFrame(key.currentState!.currentFrame)
                  .setColor(startIndex + i, selectedColor);
            });
            Navigator.of(context).pop();
          },
              key.currentState!.animation
                  .getFrame(key.currentState!.currentFrame)
                  .getColor(startIndex + i)),
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

  void colorPickerDialog(BuildContext context,
      ValueSetter<Color> onSelectAction, Color preselection) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select new color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: preselection,
              onColorChanged: (value) {
                onSelectAction(value);
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

  Widget miscTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text("Frame: " +
            (key.currentState!.currentFrame + 1).toString() +
            " / " +
            key.currentState!.animation.getTotalFrames().toString()),
        Text("Time: " +
            (key.currentState!.animation.getTotalFrames() * 0.5).toString() +
            " s"),
      ],
    );
  }

  Widget frameSelector() {
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

  Widget frameTools() {
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

  Widget paintTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          onPressed: () {
            colorPickerDialog(context, (selectedColor) {
              for (int i = 0;
                  i <
                      key.currentState!.animation
                          .getFrame(key.currentState!.currentFrame)
                          .getColors()
                          .length;
                  i++) {
                key.currentState!.animation
                    .getFrame(key.currentState!.currentFrame)
                    .setColorInt(i, colorToInt(selectedColor));
              }
              setState(() {});
              Navigator.of(context).pop();
            }, Colors.black);
          },
          child: const Icon(Icons.format_paint),
        ),
        ElevatedButton(
          onPressed: () {
            randomizeTree();
          },
          child: const Text("Randomize"),
        ),
      ],
    );
  }

  Widget fileTools() {
    List<Widget> children = [];

    Widget uploadButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.indigo,
      ),
      onPressed: !key.currentState!.esp32Api.isReady ? null : () {
        setState(() {
          uploadDataToEsp();
        });
      },
      child: const Icon(Icons.upload),
    );

    Widget saveButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.indigo,
      ),
      onPressed: onFileSavePressed,
      child: const Icon(Icons.save),
    );

    Widget shareButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.indigo,
      ),
      onPressed: onSharePressed,
      child: const Icon(Icons.share),
    );

    children.add(uploadButton);
    children.add(saveButton);
    //children.add(shareButton);
    if (key.currentState!.loadedFileName != "") {
      children.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.indigo,
          ),
          onPressed: onFileClosePressed,
          child: const Icon(Icons.close),
        ),
      );

      children.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.indigo,
          ),
          onPressed: onFileDeletePressed,
          child: const Icon(Icons.delete),
        ),
      );
    }else{
      // TODO: Needs ESP32 code to work!
      children.add(
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.indigo,
          ),
          onPressed: onRetrieveDataPressed,
          child: const Icon(Icons.download),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: children,
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
    Utils.showLoadingDialog(context, "Uploading...");

    var uploadResult = await key.currentState!.esp32Api.uploadFrame(key.currentState!.animation.toJsonData());
    if(!uploadResult) {
      Navigator.of(context).pop();

      Utils.showErrorDialog(context, "Upload failed", "Failed to upload the animation to your ESP");
      return;
    }

    setState(() {
      Navigator.of(context).pop();
    });

    Utils.showSimpleSnackbar(context, "Upload successful!");
  }

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
                if (_controller!.text == "") {
                  return;
                }
                Navigator.pop(context);
                saveFile(_controller!.text);
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
                if (_controller!.text == "") {
                  return;
                }

                Navigator.pop(context);
                shareFile(_controller!.text);
              },
            ),
          ],
        );
      },
    );
  }

  void shareFile(String title) async {
    Utils.showLoadingDialog(context, "Sharing...");

    var response = await http.post(
      Uri.parse(
          "http://" + key.currentState!.communityApi.getUrl() + "/api/creations/share"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: "{\"title\": \"" +
          title +
          "\"," +
          "\"json_data\": " +
          key.currentState!.animation.toJsonData() +
          "}",
    );

    if (response.statusCode != 200) {
      Utils.showErrorDialog(context, "Sharing failed", "Failed to share the animation");

      Navigator.of(context).pop();
      return;
    }

    Map<String, dynamic> result = jsonDecode(response.body);
    if (result["result"] != 0) {
      Utils.showErrorDialog(context, "Sharing failed", result['msg']);

      Navigator.of(context).pop();
      return;
    }

    Utils.showSimpleSnackbar(context, "Sharing successful!");

    Navigator.of(context).pop();
  }

  void saveFile(String fileName) async {
    Utils.showLoadingDialog(context, "Saving Animation...");

    var result = await saveDataToFile(
        fileName, key.currentState!.animation.toJsonData(), true);
    Navigator.pop(context);

    if (result) {
      setState(() {
        key.currentState!.loadedFileName = fileName;
      });
    }

    if (!result) {
      Utils.showErrorSnackBar(context, "File save error.");
    }else{
      Utils.showSimpleSnackbar(context, "File saved!");
    }
  }

  void onFileClosePressed() {
    setState(() {
      key.currentState!.animation = TreeAnimation();
      key.currentState!.currentFrame = 0;
      key.currentState!.loadedFileName = "";
    });
  }

  void onFileDeletePressed() async {
    if (key.currentState!.loadedFileName == "") {
      return;
    }

    Utils.showLoadingDialog(context, "Deleting Animation...");

    var result = await deleteFile(key.currentState!.loadedFileName);
    Navigator.of(context).pop();
    if (result) {
      onFileClosePressed();
    }

    if (!result) {
      Utils.showErrorSnackBar(context, "File delete error.");
    }else{
      Utils.showSimpleSnackbar(context, "File deleted!");
    }
  }

  void onRetrieveDataPressed() async {
    if (key.currentState!.loadedFileName.isNotEmpty) {
      return;
    }

    Utils.showLoadingDialog(context, "Retrieving Animation...");

    var result =
        await key.currentState!.esp32Api.retrieveAnimation();
    Navigator.of(context).pop();

    if (result == null) {
      Utils.showErrorSnackBar(context, "File retrieve error.");
    } else {

      setState(() {
        key.currentState!.animation = TreeAnimation();
        key.currentState!.animation.fromJsonData(result);

        print(key.currentState!.animation.getFrame(0).toJsonData());

        key.currentState!.currentFrame = 0;
      });
    }
  }
}
