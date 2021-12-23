import 'package:flutter/material.dart';

import 'package:esp_christmas_tree/screens/home_widget.dart';

import 'package:esp_christmas_tree/data/animation.dart';

final key = GlobalKey<HomeState>();

void main() {
  runApp(const ChristmasPCB());
}

class ChristmasPCB extends StatelessWidget {
  const ChristmasPCB({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 ChristmasPCB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(key: key),
    );
  }
}

