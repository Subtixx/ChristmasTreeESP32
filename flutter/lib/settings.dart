import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = true;
  bool notificationsEnabled = true;

  String appVersion = "?.?.?";
  String appBuild = "?";

  String ipAddress = "";

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    loadOption();
    _controller = TextEditingController(text: ipAddress);

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
    });
  }

  Future<void> saveOption(bool isSelected) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = await testApiUrl();
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text("Request to ESP32 IP failed. Please check!"),
      ));
    }

    prefs.setString('ipAddress', _controller.value.text);
    setState(() {
      ipAddress = _controller.value.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    return Scaffold(
      appBar: AppBar(title: Text('Settings UI')),
      body: Container(
        child: buildSettingsList(),
      ),
    );
  }

  Widget buildSettingsList() {
    return SettingsList(
      contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      sections: [
        SettingsSection(
          title: 'Common',
          tiles: [
            SettingsTile(
              title: "ESP32 IP",
              subtitle: ipAddress,
              leading: const Icon(Icons.cloud_queue),
              onPressed: (context) {
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 22, bottom: 8),
                child: Image.asset(
                  'assets/logo.png',
                  height: 50,
                  width: 50,
                  color: Color(0xFF777777),
                ),
              ),
              Text(
                'Version: ' + appVersion + ' (' + appBuild + ')',
                style: TextStyle(color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
