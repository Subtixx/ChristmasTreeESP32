import 'dart:convert';

import 'package:esp_christmas_tree/utils/esp32_api.dart';
import 'package:esp_christmas_tree/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  String appVersion = "?.?.?";
  String appBuild = "?";

  TextEditingController? _controller;

  String _esp32Ip = "";
  String _communityApiUrl = "";

  final List<List<String>> _changeList = [
    ['v1.2.1', 'Internal refactoring', 'Temporarily disabled sharing'],
    ['v1.2.0', 'Add sharing'],
    ['v1.1.0', 'Add community tab'],
    ['v1.0.0', 'First initial release'],
  ];

  @override
  void initState() {
    super.initState();

    _esp32Ip = key.currentState!.esp32Api.getIp();
    _communityApiUrl = key.currentState!.communityApi.getUrl();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
      });
    });
  }

  Future<void> saveOption(bool isSelected) async {
    Utils.showLoadingDialog(context, "Checking connection to ESP32...");

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    var validUrl = Uri.tryParse("http://" + _esp32Ip) != null ? true : false;
    if (!validUrl) {
      Navigator.of(context).pop();

      Utils.showErrorDialog(
          context, "Invalid IP", "Specified ESP32 IP is invalid.");
      return;
    }

    var esp32Api = Esp32Api(_esp32Ip);
    var espApiResult = await esp32Api.testConnection(context);
    if (!espApiResult) {
      Navigator.of(context).pop();

      Utils.showErrorDialog(context, "Connection to ESP32 failed",
          "Request to ESP32 IP failed. Please check!");
      return;
    }
    Navigator.of(context).pop();

    setState(() {
      key.currentState!.esp32Api.setIp(_esp32Ip);
      key.currentState!.communityApi.setUrl(_communityApiUrl);
    });

    prefs.setString('ipAddress', key.currentState!.esp32Api.getIp());
    prefs.setString('communityUrl', key.currentState!.communityApi.getUrl());

    Utils.showSimpleSnackbar(context, "Settings saved!");

    key.currentState!.refresh();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSettingsList();
  }

  Widget buildSettingsList() {
    return SettingsList(
      contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      sections: [
        SettingsSection(
          title: 'Common',
          tiles: [
            SettingsTile(
              title: "ESP32 IP",
              subtitle: _esp32Ip,
              leading: const Icon(Icons.cloud_queue),
              onPressed: onSaveEsp32Ip,
            ),
            SettingsTile(
              title: "API URL",
              subtitle: _communityApiUrl,
              leading: const Icon(Icons.cloud_queue),
              onPressed: onSaveCommunityApiUrl,
            ),
          ],
        ),
        CustomSection(
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: ListView.builder(
                      itemBuilder: (c, i) {
                        return ListTile(
                          title: Text(_changeList[i][0]),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                color: Color(0xFFDDDDDD),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: getChangesWidget(i),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: _changeList.length,
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  );
                },
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22, bottom: 8),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 50,
                    width: 50,
                    color: const Color(0xFF777777),
                  ),
                ),
                Text(
                  'Version: ' + appVersion + ' (Build ' + appBuild + ')',
                  style: const TextStyle(color: Color(0xFF777777)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> getChangesWidget(int idx) {
    List<Widget> result = [];
    for (var i = 1; i < _changeList[idx].length; i++) {
      result.add(Text(_changeList[idx][i]));
    }
    return result;
  }

  void onSaveEsp32Ip(BuildContext context) {
    _controller = TextEditingController(text: _esp32Ip);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set IP of ESP32'),
          content: SingleChildScrollView(
            child: TextFormField(
              controller: _controller,
              decoration: const InputDecoration(hintText: "IP Address"),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  _esp32Ip = _controller!.value.text;
                });

                saveOption(false);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void onSaveCommunityApiUrl(BuildContext context) {
    _controller = TextEditingController(text: _communityApiUrl);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set URL of community'),
          content: SingleChildScrollView(
            child: TextFormField(
              controller: _controller,
              decoration:
                  const InputDecoration(hintText: "eg http://192.168.1.1/api"),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                try {
                  Uri.parse("http://" +
                      key.currentState!.communityApi.getUrl() +
                      "/api/creations/share");
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text("Invalid community url"),
                  ));
                  return;
                }

                setState(() {
                  key.currentState!.communityApi.setUrl(_controller!.value.text);
                });

                saveOption(false);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
