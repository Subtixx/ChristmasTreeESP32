import 'package:esp_christmas_tree/data/animation.dart';
import 'package:esp_christmas_tree/screens/animation_list_widget.dart';
import 'package:esp_christmas_tree/screens/community_widget.dart';
import 'package:esp_christmas_tree/screens/placeholder_widget.dart';
import 'package:esp_christmas_tree/screens/settings_widget.dart';
import 'package:esp_christmas_tree/screens/tree_widget.dart';
import 'package:esp_christmas_tree/utils/community_api.dart';
import 'package:esp_christmas_tree/utils/esp32_api.dart';
import 'package:esp_christmas_tree/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String loadedFileName = "";

  Esp32Api esp32Api = Esp32Api("");
  CommunityApi communityApi = CommunityApi("");

  TreeWidget? _treeWidget;

  @override
  void initState() {
    super.initState();

    _treeWidget = TreeWidget(connectionTest: esp32Api.testConnection(context));
    _children = [
      _treeWidget!,
      const AnimationListWidget(),
      const CommunityWidget(),
      const SettingsWidget(),
    ];

    loadOption();
  }

  void refresh()
  {
    setState(() {
      _treeWidget = TreeWidget(connectionTest: esp32Api.testConnection(context));
      _children = [
        _treeWidget!,
        const AnimationListWidget(),
        const CommunityWidget(),
        const SettingsWidget(),
      ];
    });
  }

  Future<void> loadOption() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      esp32Api.setIp(prefs.getString('ipAddress') ?? "");
      communityApi.setUrl(prefs.getString('communityUrl') ?? "");
    });

    var connectionSuccessful = await esp32Api.testConnection(context);
    if (!connectionSuccessful) {
      Utils.showErrorSnackBar(
          context, "Connection failed: Please check your connection settings");
    }

    // TODO: Here is a bug. The upload button sometimes is still disabled.
  }

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
  late List<Widget> _children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChristmasPCB"),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.primaries[5],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.animation),
            label: 'My Files',
            backgroundColor: Colors.primaries[5],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.perm_media),
            label: 'Community',
            backgroundColor: Colors.primaries[5],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.primaries[5],
          ),
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
