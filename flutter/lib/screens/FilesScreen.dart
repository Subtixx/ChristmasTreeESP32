import 'package:christmas_pcb/utils.dart';
import 'package:christmas_pcb/screens/CreateScreen.dart';
import 'package:christmas_pcb/widgets/GalleryContainer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FilesScreen extends StatefulWidget {
  const FilesScreen({Key? key}) : super(key: key);

  @override
  _FilesScreenState createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  List<AnimationFile> animations = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Utils.saveDataToFile("my_awesome_anim.json", "[[1, 2, 3, 4, 5]]");
    Utils.saveDataToFile(
        "i am a file name with spaces that hopefully also works.json",
        "[[5, 4, 3, 2, 1]]");
    isLoading = true;

    populateAnimationList();
  }

  void populateAnimationList() async {
    var files = await Utils.getAllFiles();
    if (files == null) return;

    var animationFiles = [];
    for (var i = 0; i < files.length; i++) {
      if (!files[i].endsWith(".json")) continue;

      // TODO: Replace with an actual name + actual preview
      animationFiles.add(AnimationFile(
          path
              .basename(files[i])
              .substring(0, path.basename(files[i]).length - 5),
          "https://via.placeholder.com/240?text=WIP",
          false));
    }

    setState(() {
      animations = List.from(animationFiles);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
      ),
      itemCount: animations.length,
      itemBuilder: (context, index) {
        return retImage(context, index, animations[index]);
      },
    );
  }

  Widget retImage(
      BuildContext context, int index, AnimationFile animationFile) {
    Container cont = Container(
        padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
        decoration: const BoxDecoration(
          color: Color.fromARGB(200, 20, 20, 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                animationFile.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: Colors.white,
                ),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ));

    Stack stack = Stack(
      children: <Widget>[
        Stack(
          children: <Widget>[
            /*Image.asset(
              "images/" + image + ".jpg",
              fit: BoxFit.cover,
              height: 240.0,
            )*/
            Image.network(
              animationFile.image,
              fit: BoxFit.cover,
              height: 240,
            ),
          ],
        ),
        Positioned(child: cont, bottom: 0.0, right: 0.0, left: 0.0)
      ],
    );

    return InkWell(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: double.minPositive,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    /*ListTile(
                      title: const Text("Rename"),
                      leading:
                          const Icon(Icons.drive_file_rename_outline_sharp),
                      onTap: () async {
                        Navigator.of(context).pop();

                        String newName = await Utils.showSimpleInputDialog(
                            context, "Enter new name");
                        if (newName.isEmpty) {
                          return;
                        }
                      },
                    ),*/
                    ListTile(
                      title: const Text("Delete"),
                      leading: const Icon(Icons.delete),
                      onTap: () async {
                        Navigator.of(context).pop();

                        bool result = await Utils.showSimpleConfirmDialog(
                            context, "Delete '" + animationFile.title + "'?");
                        if (result) {
                          await Utils.deleteFile(animationFile.title + ".json");
                          setState(() {
                            animations.removeAt(index);
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      onTap: () async {
        var data = await Utils.readDataFromFile(animationFile.title + ".json");
        if (data == null) {
          setState(() {
            animations.removeAt(index);
          });
          Utils.showSimpleSnackbar(context, "Failed to load file");
          return;
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CreateScreen(animationFile.title, data);
            },
          ),
        );
      },
      child: stack,
    );
  }
}
