import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Esp32Api {
  String _esp32Ip;

  bool isReady = false;

  Esp32Api(this._esp32Ip)
  {
    var validUrl = Uri.tryParse("http://" + _esp32Ip) != null ? true : false;
    if (!validUrl) {
      debugPrint(_esp32Ip);

      isReady = false;
      throw Exception('Invalid IP address');
    }
  }

  /// Set the IP address/Hostname of the ESP32, throws an exception if the IP/Hostname is invalid
  void setIp(String ip) {
    var validUrl = Uri.tryParse("http://" + ip) != null ? true : false;
    if (!validUrl) {
      debugPrint(ip);

      isReady = false;
      throw Exception('Invalid IP address');
    }

    _esp32Ip = ip;
  }

  /// Get the IP address/Hostname of the ESP32
  String getIp() {
    return _esp32Ip;
  }

  /// Tests connection to ESP32
  Future<bool> testConnection() async {
    http.Response response;
    try {
      response = await http
          .get(Uri.http(_esp32Ip, "/"))
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });
    } catch (e) {
      debugPrint(e.toString());

      isReady = false;
      return false;
    }

    // TODO: ESP32 returns an error on other routes than /post
    isReady = true;
    return true;
    /*isReady = response.statusCode == 200;
    return isReady;*/
  }

  /// Uploads the specified animation to the ESP32.
  Future<bool> uploadFrame(String frameJson) async {
    http.Response response;
    try {
      response = await http
          .post(
        Uri.http(_esp32Ip, "/post"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: frameJson,
      )
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, Please try again!');
      });
    } catch (_) {
      isReady = false;
      return false;
    }

    if (response.statusCode != 200) {
      return false;
    }

    Map<String, dynamic> result = jsonDecode(response.body);
    if (result["result"] != 0) {
      return false;
    }

    return true;
  }
}
