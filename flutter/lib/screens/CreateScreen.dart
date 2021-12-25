import 'package:christmas_pcb/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateScreen extends StatefulWidget {
  String animationData;

  CreateScreen([this.animationData = ""]);

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive,
        overlays: [SystemUiOverlay.top]);

    if (widget.animationData.isEmpty) {
      return;
    }

    print(widget.animationData);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await Utils.showSimpleConfirmDialog(
            context, "Discard unsaved changes?");
      },
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.primary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(25, 0, 25, 0)),
                IconButton(
                  icon: const Icon(Icons.keyboard_return),
                  onPressed: () async {
                    var result = await Utils.showSimpleConfirmDialog(
                        context, "Discard unsaved changes?");
                    if (result) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: () {},
                ),
                const IconButton(
                  icon: Icon(Icons.download),
                  onPressed: null,
                ),
                const IconButton(
                  icon: Icon(Icons.close),
                  onPressed: null,
                ),
                const Padding(padding: EdgeInsets.fromLTRB(25, 0, 25, 0)),
              ],
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(10),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Text("my_awesome_animation"),
                  ],
                ),
              ),
              paintTools(),
              const Spacer(),
              treeRow(0, 1),
              treeRow(1, 2),
              treeRow(3, 2),
              treeRow(5, 1),
              const Spacer(),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Text("Frame 9 / 10"),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Text("Total: 1.5 s"),
                  ],
                ),
              ),
              frameSelector(),
              frameTools(),
              Container(
                margin: const EdgeInsets.all(10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(0.0),
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget treeRow(int startIndex, int count) {
    List<Widget> treeButtons = [];
    for (int i = 0; i < count; i++) {
      treeButtons.add(
        ElevatedButton(
          onPressed: () => {},
          child: const Text(""),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
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

  Widget frameTools() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Icon(Icons.add),
                  Text("Add"),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Icon(Icons.content_copy),
                  Text("Copy"),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Icon(Icons.ac_unit),
                  Text("Add Random"),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Icon(Icons.delete),
                  Text("Remove last"),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Icon(Icons.delete_forever),
                  Text("Clear"),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget frameSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Icon(Icons.skip_previous),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Icon(Icons.slideshow),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Icon(Icons.skip_next),
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
          onPressed: () {},
          child: Row(
            children: const [
              Icon(Icons.format_paint),
              Text("Fill"),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          child: Row(
            children: const [
              Icon(Icons.assistant_direction),
              Text("Randomize"),
            ],
          ),
        ),
      ],
    );
  }
}
