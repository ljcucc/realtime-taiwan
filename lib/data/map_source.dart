import 'package:flutter/material.dart';

const MapTileOptions = [
  MapTileOption(
    url: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    name: "OpenStreetMap",
  ),
  MapTileOption(
    url: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
    name: "Google Maps",
  ),
];

class MapTileOption {
  final String url;
  final String name;

  const MapTileOption({
    required this.url,
    required this.name,
  });
}

class MapSourceModel extends ChangeNotifier {
  MapTileOption? type;

  void setType(MapTileOption type) {
    this.type = type;
    notifyListeners();
  }
}
