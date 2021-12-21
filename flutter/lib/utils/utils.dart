import 'package:flutter/material.dart';

class Utils {
  static void showSimpleSnackbar(BuildContext context, String message, [int timeoutSeconds = 1]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: timeoutSeconds),
      content: Text(message),
    ));
  }

  static void showSimpleDialog(BuildContext context, String title, String text,
      [bool dismissable = true]) {
    if (dismissable) {
      showDialog(
        context: context,
        barrierDismissible: dismissable,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: dismissable,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(title),
              content: Text(text),
            ),
          );
        },
      );
    }
  }

  static void showLoadingDialog(BuildContext context, [String message = ""]) {
    if (message.isEmpty) {
      message = "Loading...";
    } else if (message.length > 20) {
      message = message.substring(0, 20) + "...";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                Container(
                    margin: const EdgeInsets.only(left: 7),
                    child: Text(message)),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showErrorDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showErrorSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 25),
      content: Text(title),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
}
