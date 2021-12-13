import 'dart:convert';

import 'package:flutter/material.dart';

List<Color> colorList = const [
  Colors.black,
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow
];

int colorToInt(Color clr) {
  return colorList.indexOf(clr);
}

Color intToColor(int clr) {
  return colorList[clr];
}

class TreeFrame {
  List<Color> _colors = [];

  TreeFrame([List<Color>? frame]) {
    if (frame == null) {
      _colors = [
        Colors.black,
        Colors.black,
        Colors.black,
        Colors.black,
        Colors.black,
        Colors.black
      ];
      return;
    }
    _colors = List.from(frame);
  }

  List<int> _colorsAsInt() {
    List<int> _result = [];
    for (Color clr in _colors) {
      _result.add(colorToInt(clr));
    }
    return _result;
  }

  void fromJsonList(List<dynamic> frame) {
    _colors.clear();
    for (int clr in frame) {
      _colors.add(intToColor(clr));
    }
  }

  String toJsonData() {
    return jsonEncode(_colorsAsInt());
  }

  Color getColor(int idx) {
    return _colors[idx];
  }

  void setColor(int idx, Color clr) {
    _colors[idx] = clr;
  }

  List<Color> getColors() {
    return List.from(_colors);
  }

  void setColorInt(int idx, int clr) {
    _colors[idx] = intToColor(clr);
  }
}

class TreeAnimation {
  List<TreeFrame> _frames = [TreeFrame()];

  String toJsonData() {
    String _result = "";

    var i = 0;
    for (TreeFrame frame in _frames) {
      _result += frame.toJsonData();
      if (i < _frames.length - 1) _result += ",";
      i++;
    }
    return "[" + _result + "]";
  }

  void fromJsonData(String data) {
    _frames.clear();

    //[[1,1,1,1,]]
    List<dynamic> jsonDecodedData = jsonDecode(data);
    for (List<dynamic> frame in jsonDecodedData) {
      var f = TreeFrame();
      f.fromJsonList(frame);
      _frames.add(f);
    }
  }

  TreeFrame getFrame(int idx) {
    return _frames[idx];
  }

  void setFrame(int idx, List<Color> colors) {
    if (idx > _frames.length - 1) {
      _frames.add(TreeFrame(List.from(colors)));
    } else {
      _frames[idx]._colors = List.from(colors);
    }
  }

  int getTotalFrames() {
    return _frames.length;
  }

  /// TODO:
  int getFrameIndex(TreeFrame value) {
    return _frames.indexOf(value);
  }

  List<TreeFrame> getFrames() {
    return List.from(_frames);
  }

  void addFrame(TreeFrame treeFrame) {
    _frames.add(treeFrame);
  }

  int removeLastFrame() {
    _frames.removeAt(_frames.length - 1);
    return _frames.length;
  }

  TreeFrame getLastFrame() {
    return _frames[_frames.length - 1];
  }
}
