import 'package:esp_christmas_tree/data/animation.dart';
import 'package:esp_christmas_tree/screens/animation_list_widget.dart';
import 'package:esp_christmas_tree/screens/community_widget.dart';
import 'package:esp_christmas_tree/screens/placeholder_widget.dart';
import 'package:esp_christmas_tree/screens/settings_widget.dart';
import 'package:esp_christmas_tree/screens/tree_widget.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State createState() {
    return HomeState();
  }
}

class HomeState extends State {
  TreeAnimation animation = TreeAnimation();
  int currentFrame = 0;

  String activeAnimation = "[]";

  String espIp = "127.0.0.1";
  String communityUrl = "192.168.1.214";

  String loadedFileName = "";

  void setAnimation(String anim) {
    setState(() {
      animation.fromJsonData(anim);

      currentFrame = 0;
    });
  }

  void setTab(int tab) {
    if (tab > _children.length - 1) {
      return;
    }

    setState(() {
      _currentIndex = tab;
    });
  }

  int _currentIndex = 0;
  final List _children = [
    const TreeWidget(),
    const AnimationListWidget(),
    const CommunityWidget(),
    const SettingsWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChristmasPCB"),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.primaries[5],
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.primaries[5]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.animation),
              label: 'My Files',
              backgroundColor: Colors.primaries[5]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.perm_media),
              label: 'Community',
              backgroundColor: Colors.primaries[5]),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: 'Settings',
              backgroundColor: Colors.primaries[5]),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
