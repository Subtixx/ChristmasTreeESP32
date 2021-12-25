import 'package:christmas_pcb/utils.dart';
import 'package:christmas_pcb/screens/CreateScreen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AnimationFile {
  String title;
  String image;
  bool isFavorite;
  String username;

  AnimationFile(this.title, this.image, this.isFavorite,
      [this.username = "anonymous"]);
}

class GalleryContainer extends StatefulWidget {
  const GalleryContainer({Key? key}) : super(key: key);

  @override
  _GalleryContainerState createState() => _GalleryContainerState();
}

class _GalleryContainerState extends State<GalleryContainer> {
  List<AnimationFile> animations = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    isLoading = true;

    populateAnimationList();
  }

  void populateAnimationList() async {
    var files = await getAllFiles();
    files!.add("my_awesome_anim.json");

    var animationFiles = [];
    for (var i = 0; i < files.length; i++) {
      animationFiles.add(AnimationFile(
          files[i], "https://via.placeholder.com/240?text=WIP", false));
    }

    setState(() {
      animations = List.from(animationFiles);
      isLoading = false;
    });
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
          color: Color.fromARGB(220, 20, 20, 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  animationFile.title.length > 14
                      ? animationFile.title.substring(0, 14) + "..."
                      : animationFile.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "By " + animationFile.username,
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[200],
                      fontSize: 10.0),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "Added 12/24/2021 5:19 PM",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[200],
                      fontSize: 10.0),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 24,
              onPressed: () {
                setState(() {
                  animations[index].isFavorite = !animations[index].isFavorite;
                });
              },
              icon: animationFile.isFavorite
                  ? const Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )
                  : const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
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
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateScreen(),
          ),
        );
      },
      child: stack,
    );
  }
}
