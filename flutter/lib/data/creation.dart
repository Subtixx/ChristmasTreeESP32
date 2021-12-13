import 'package:flutter/material.dart';

import '../main.dart';

class Creation {
  /// Name of the creation set by user
  final String _name;

  /// Description of the creation set by user
  final String _description;

  /// Create date of the creation
  final String _postDate;

  /// JSON Encoded LED Data of the creation.
  final String _jsonData;

  final String _posterName;

  String get name => _name;

  String get description => _description;

  String get postDate => _postDate;

  String get jsonData => _jsonData;

  String get posterName => _posterName;

  Creation(this._name, this._description, this._postDate, this._posterName,
      this._jsonData);

  Widget getWidget() {
    return InkWell(
      onTap: () {
        key.currentState!.setAnimation(jsonData);
        key.currentState!.setTab(0);
      },
      child: ListTile(
        title: Text(name),
        subtitle: Text(description),
        trailing: Text(postDate + "\nby " + posterName),
      ),
    );
  }
}
