import 'dart:convert';

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
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  String appVersion = "?.?.?";
  String appBuild = "?";

  String ipAddress = "559713fa-6c9c-48fc-acac-179770aa82ad.mock.pstmn.io";
  String communityUrl = "http://192.168.1.214/api";

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    loadOption();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
      });
    });
  }

  Future<void> loadOption() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = prefs.getString('ipAddress')!;
      communityUrl = prefs.getString('communityUrl')!;
    });
  }

  Future<void> saveOption(bool isSelected) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await testApiUrl();
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("Request to ESP32 IP failed. Please check!"),
      ));
    }

    prefs.setString('ipAddress', ipAddress);
    prefs.setString('communityUrl', communityUrl);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Communication success!"),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Future<http.Response> testApiUrl() {
    return http.post(
      Uri.parse("http://" + ipAddress + "/post"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: "[]",
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSettingsList();
  }

  List<List<String>> _changeList = [
    ['v1.2.0', 'Add sharing'],
    ['v1.1.0', 'Add community tab'],
    ['v1.0.0', 'First initial release'],
  ];

  Widget buildSettingsList() {
    return SettingsList(
      contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      sections: [
        SettingsSection(
          title: 'Common',
          tiles: [
            SettingsTile(
              title: "ESP32 IP",
              subtitle: ipAddress,
              leading: const Icon(Icons.cloud_queue),
              onPressed: (context) {
                // TODO: Load from prefs?
                _controller = TextEditingController(text: ipAddress);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Set IP of ESP32'),
                      content: SingleChildScrollView(
                        child: TextFormField(
                          controller: _controller,
                          decoration:
                              const InputDecoration(hintText: "IP Address"),
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
                              ipAddress = _controller.value.text;
                              key.currentState!.espIp = ipAddress;
                            });

                            saveOption(false);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SettingsTile(
              title: "API URL",
              subtitle: communityUrl,
              leading: const Icon(Icons.cloud_queue),
              onPressed: (context) {
                // TODO: Load from prefs?
                _controller = TextEditingController(text: communityUrl);

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
                              Uri.parse("http://" + key.currentState!.communityUrl + "/api/creations/share");
                            }catch(_){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text("Invalid community url"),
                              ));
                              return;
                            }
                            setState(() {
                              communityUrl = _controller.value.text;
                              key.currentState!.communityUrl = communityUrl;
                            });

                            saveOption(false);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
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
}
