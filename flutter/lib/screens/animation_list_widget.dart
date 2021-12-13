import 'package:path/path.dart' as path;

import 'package:esp_christmas_tree/data/saved_files.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class AnimationListWidget extends StatefulWidget {
  const AnimationListWidget({Key? key}) : super(key: key);

  @override
  _AnimationListWidgetState createState() => _AnimationListWidgetState();
}

class _AnimationListWidgetState extends State<AnimationListWidget> {
  List<String> _files = [];

  @override
  void initState() {
    super.initState();

    loadFiles();
  }

  void loadFiles() async {
    List<String>? files = await getAllFiles();
    if (files == null) return;

    setState(() {
      _files = List.from(files);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (c, i) {
        return InkWell(
          onTap: () {
            load(i);
          },
          child: ListTile(
            title: Text(path.basename(_files[i]).substring(0, path.basename(_files[i]).length - 5)),
            subtitle: Text(""),
            trailing: Text(""),
          ),
        );
      },
      itemCount: _files.length,
      separatorBuilder: (context, index) {
        return const Divider(
          height: .5,
          color: Color(0xFFDDDDDD),
        );
      },
    );
  }

  void load(int idx) async {
    showSimpleDialog("Loading..", "Loading animation!", false);
    var fullPath = path.basename(_files[idx]);
    var name = path.basename(_files[idx]).substring(0, path.basename(_files[idx]).length - 5);

    var data = await readDataFromFile(name);
    if (data != null) {
      key.currentState!.loadedFileName = name;
      key.currentState!.setAnimation(data);
      key.currentState!.setTab(0);
    }
    Navigator.of(context).pop();
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
}
