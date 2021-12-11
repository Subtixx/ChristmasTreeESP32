// TODO: Maybe a community tab, to place community made animations =).
import 'dart:convert';

import 'package:esp_christmas_tree/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

final _random = new Random();

/// Generates a positive random integer uniformly distributed on the range
/// from [min], inclusive, to [max], exclusive.
int next(int min, int max) => min + _random.nextInt(max - min);

// TODO: Animations

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 ChristmasPCB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Color> currentColors = [
    Colors.yellow, // TOP
    Colors.green, // MIDDLE LEFT
    Colors.green, //  MIDDLE RIGHT
    Colors.yellow, //  BOTTOM LEFT
    Colors.green, // BOTTOM RIGHT
    Colors.yellow, // MIDDLE BOTTOM
  ];

  int activeFrameNum = 0;
  List<List<Color>> Frames = [
    [Colors.red, Colors.red, Colors.red, Colors.red, Colors.red, Colors.red],
    [
      Colors.green,
      Colors.green,
      Colors.green,
      Colors.green,
      Colors.green,
      Colors.green
    ],
    [
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.blue,
      Colors.blue
    ],
  ];

  String ipAddress = "";

  bool buttonsEnabled = true;

  var colorSelection = const [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.black
  ];

  @override
  void initState() {
    super.initState();

    currentColors = List.from(Frames[0]);

    buttonsEnabled = true;

    loadOption();
  }

  void changeColor(int index, Color color) {
    setState(() {
      Frames[activeFrameNum][index] = color;
      currentColors[index] = color;
    });
    Navigator.of(context).pop();
  }

  void changeColors(List<Color> colors) =>
      setState(() => currentColors = List.from(colors));

  Future<void> loadOption() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = prefs.getString('ipAddress')!;
    });
  }

  List<Widget> buildFillSelection() {
    List<Widget> widgets = [];
    for (var value in colorSelection) {
      widgets.add(ElevatedButton(
        onPressed: () {
          fillTree(value);
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(value)),
        child: Text("",
            style: TextStyle(
                color:
                    useWhiteForeground(value) ? Colors.white : Colors.black)),
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Christmas Tree ESP32'),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const SettingsScreen();
                      },
                    ),
                  );
                },
                child: const Icon(
                  Icons.settings,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FrameTools(),
            // Frame selection
            FrameSelector(),
            // Toolbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Frame: " +
                    (activeFrameNum + 1).toString() +
                    " / " +
                    Frames.length.toString()),
                ElevatedButton(
                  onPressed: () {
                    randomizeTree();
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.deepPurple)),
                  child: const Text("Randomize"),
                ),
                Text("Time: " + (Frames.length * 0.5).toString() + " s"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: buildFillSelection(),
            ),

            Container(
              margin: const EdgeInsets.all(10),
            ),

            treeRow(0, true),
            treeRow(1),
            treeRow(3),
            treeRow(5, true),

            Container(
              margin: const EdgeInsets.all(10),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          buttonsEnabled ? Colors.primaries[5] : Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: const [Icon(Icons.upload), Text("Upload")],
                    ),
                    onPressed: onSavePressed,
                  ),
                ),
              ],
            ),
          ],
        ),
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.center,
      ),
    );
  }

  void setActiveFrame(int frameNumber) {
    if (frameNumber >= Frames.length || frameNumber < 0) {
      return;
    }

    var activeFrame = Frames[frameNumber];
    setState(() {
      currentColors = List.from(activeFrame);

      activeFrameNum = frameNumber;
    });
  }

  void onSavePressed() {
    if (!buttonsEnabled) return;

    if (ipAddress == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("Cannot connect! Please check IP of ESP32"),
      ));
      return;
    }

    setState(() {
      buttonsEnabled = false;
    });
    sendDataToAPI();
  }

  int colorToInt(Color color) {
    if (color == Colors.black) {
      return 0;
    } else if (color == Colors.red) {
      return 1;
    } else if (color == Colors.green) {
      return 2;
    } else if (color == Colors.blue) {
      return 3;
    } else if (color == Colors.yellow) {
      return 4;
    }
    return 0;
  }

  Color intToColor(int colorType) {
    if (colorType == 0) {
      return Colors.black;
    } else if (colorType == 1) {
      return Colors.red;
    } else if (colorType == 2) {
      return Colors.green;
    } else if (colorType == 3) {
      return Colors.blue;
    } else if (colorType == 4) {
      return Colors.yellow;
    }
    return Colors.black;
  }

  Future<void> sendDataToAPI() async {
    var frames = "[";
    var i = 0;
    for (List<Color> frame in Frames) {
      var singleFrameColors = "[";

      var j = 0;
      for (Color color in frame) {
        singleFrameColors += colorToInt(color).toString();
        if (j < frame.length - 1) {
          singleFrameColors += ",";
        }
        j++;
      }
      singleFrameColors += "]";
      if (i < Frames.length - 1) {
        singleFrameColors += ",";
      }

      frames += singleFrameColors;
      i++;
    }
    frames += "]";

    var response = await http.post(
      Uri.parse("http://" + ipAddress + "/post"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: frames,
    );

    // TODO: Saving to mobile phone storage!

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("Request to ESP32 IP failed. Please check IP and ESP!"),
      ));
      return;
    }

    Map<String, dynamic> result = jsonDecode(response.body);
    if (result["result"] != 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(result["msg"]),
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Upload succeeded!"),
    ));

    setState(() {
      buttonsEnabled = true;
    });
  }

  Widget treeRow(int start, [bool specialRow = false]) {
    // TODO: Use a count instead of special row.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: specialRow
          ? [
              ElevatedButton(
                key: null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      buttonsEnabled ? currentColors[start] : Colors.grey),
                ),
                onPressed: () {
                  if (!buttonsEnabled) return;

                  colorPickerDialog(context, start);
                },
                child: Text(
                  "",
                  style: TextStyle(
                      color: useWhiteForeground(currentColors[start])
                          ? Colors.white
                          : Colors.black),
                ),
              ),
            ]
          : [
              ElevatedButton(
                key: null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      buttonsEnabled ? currentColors[start] : Colors.grey),
                ),
                onPressed: () {
                  colorPickerDialog(context, start);
                },
                child: Text(
                  "",
                  style: TextStyle(
                      color: useWhiteForeground(currentColors[start])
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              ElevatedButton(
                key: null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      buttonsEnabled ? currentColors[start + 1] : Colors.grey),
                ),
                onPressed: () {
                  colorPickerDialog(context, start + 1);
                },
                child: Text(
                  "",
                  style: TextStyle(
                      color: useWhiteForeground(currentColors[start + 1])
                          ? Colors.white
                          : Colors.black),
                ),
              ),
            ],
    );
  }

  void colorPickerDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select new color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColors[index],
              onColorChanged: (value) {
                changeColor(index, value);
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

  void fillTree(Color newValue) {
    for (var i = 0; i < currentColors.length; i++) {
      setState(() {
        currentColors[i] = newValue;
        Frames[activeFrameNum][i] = newValue;
      });
    }
  }

  void randomizeTree() {
    for (var i = 0; i < currentColors.length; i++) {
      setState(() {
        var randColor = next(0, 4);
        var color = Colors.black;

        if (randColor == 0) {
          color = Colors.black;
        } else if (randColor == 1) {
          color = Colors.red;
        } else if (randColor == 2) {
          color = Colors.green;
        } else if (randColor == 3) {
          color = Colors.blue;
        } else if (randColor == 4) {
          color = Colors.yellow;
        }

        currentColors[i] = color;
      });
    }
  }

  Widget FrameTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Frames.length >= 256 ? Colors.grey : Colors.primaries[5],
            ),
          ),
          onPressed: () {
            if (Frames.length >= 256) {
              return;
            }

            setState(() {
              Frames.add([
                Colors.black,
                Colors.black,
                Colors.black,
                Colors.black,
                Colors.black,
                Colors.black
              ]);
              setActiveFrame(Frames.length - 1);
            });
          },
          child: const Icon(Icons.add),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Frames.length == 1 ? Colors.grey : Colors.primaries[5],
            ),
          ),
          onPressed: () {
            if (Frames.length == 1) {
              return;
            }
          },
          child: const Icon(Icons.slideshow),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Frames.length > 1 ? Colors.primaries[5] : Colors.grey,
            ),
          ),
          onPressed: () {
            if (Frames.length == 1) {
              return;
            }

            setState(() {
              Frames.removeAt(Frames.length - 1);
              if (activeFrameNum == Frames.length - 1) {
                setActiveFrame(Frames.length - 1);
              }
            });
          },
          child: const Icon(Icons.delete),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              Frames.length >= 256 ? Colors.grey : Colors.primaries[5],
            ),
          ),
          onPressed: () {
            if (Frames.length >= 256) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(seconds: 1),
                content: Text("Too many frames!"),
              ));
              return;
            }

            setState(() {
              Frames.add(List.from(Frames[activeFrameNum]));
              setActiveFrame(Frames.length - 1);
            });
          },
          child: const Icon(Icons.content_copy),
        ),
      ],
    );
  }

  Widget FrameSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                activeFrameNum > 0 ? Colors.primaries[5] : Colors.grey),
          ),
          onPressed: () {
            setActiveFrame(activeFrameNum - 1);
          },
          child: const Icon(Icons.skip_previous),
        ),
        DropdownButton<String>(
          value: activeFrameNum.toString(),
          items: Frames.map((List<Color> value) {
            var index = Frames.indexOf(value);
            return DropdownMenuItem<String>(
              value: index.toString(),
              child: Text("Frame " + (index+1).toString()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              activeFrameNum = int.parse(value!);
              setActiveFrame(activeFrameNum);
            });
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                activeFrameNum < Frames.length - 1
                    ? Colors.primaries[5]
                    : Colors.grey),
          ),
          onPressed: () {
            setActiveFrame(activeFrameNum + 1);
          },
          child: const Icon(Icons.skip_next),
        ),
      ],
    );
  }
}
