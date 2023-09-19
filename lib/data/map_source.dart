import 'package:flutter/material.dart';

const MapTileOptions = [
  MapTileOption(
    url: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
    name: "Google Maps",
  ),
  MapTileOption(
    url: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    name: "OpenStreetMap",
    description:
        "This option will use offical tile server, aware of the large usage.",
  ),
];

class MapTileOption {
  final String url;
  final String name;
  final String? description;
  final Builder? customBuilder;

  const MapTileOption({
    required this.url,
    required this.name,
    this.description,
    this.customBuilder,
  });

  get subtitle => description != null ? Text(description!) : null;
}

class CustomMapTileOption {}

class MapSourceModel extends ChangeNotifier {
  MapTileOption type = MapTileOptions[0];

  void setType(MapTileOption type) {
    this.type = type;
    notifyListeners();
  }
}
