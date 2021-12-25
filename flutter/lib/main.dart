import 'dart:convert';

import 'package:christmas_pcb/screens/CreateScreen.dart';
import 'package:christmas_pcb/screens/FavoritesScreen.dart';
import 'package:christmas_pcb/screens/FilesScreen.dart';
import 'package:christmas_pcb/screens/SearchScreen.dart';
import 'package:christmas_pcb/screens/SettingsScreen.dart';
import 'package:christmas_pcb/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const appTitle = '🎄 PCB';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'OpenSans'),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive,
        overlays: [SystemUiOverlay.top]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎄 PCB"),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () async {
              var result = await Utils.showSimpleInputDialog(
                  context, _textEditingController, "Paste");
              var fileName = "imported_" + DateTime.now().millisecondsSinceEpoch.toString();
              try {
                var dummy = jsonDecode(result);
                if(dummy is Map<String, String>) {
                  if (dummy.containsKey("title")) {
                    fileName = dummy['title']!;
                  }
                }
              } catch (_) {
                Utils.showSimpleSnackbar(context, "Invalid JSON");
                return;
              }

              Utils.saveDataToFile(fileName + ".json", result);
            },
            tooltip: "Import from string",
          )
        ],
      ),
      body: const FilesScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CreateScreen(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.primary),
          child: Row(
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(25, 0, 25, 0)),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.fromLTRB(25, 0, 25, 0)),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                "🎄 PCB",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const ListTile(
              title: Text("Version 1.0.0"),
            ),
          ],
        ),
      ),
    );
  }
}
