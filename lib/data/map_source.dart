import 'package:flutter/material.dart';

// TODO: fix enum type and string type issue
class MapSourceModel extends ChangeNotifier {
  String? source;

  void fetchPreference() {}

  void setSource(String url) {
    source = url;
    notifyListeners();
  }
}
