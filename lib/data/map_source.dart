import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/lang.dart';

var MapTileOptions = [
  MapTileOption(
    url: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
    name: Text("Google Maps"),
  ),
  MapTileOption(
    url: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    name: Text("OpenStreetMap"),
    description: Builder(builder: (context) {
      return Text(lang(context).mapselector_osm_subtitle);
    }),
  ),
];

class MapTileOption {
  final String url;
  final Widget name;
  final Widget? description;
  final Builder? customBuilder;

  const MapTileOption({
    required this.url,
    required this.name,
    this.description,
    this.customBuilder,
  });
}

class CustomMapTileOption {}

class MapSourceModel extends ChangeNotifier {
  MapTileOption type = MapTileOptions[0];

  void setType(MapTileOption type) {
    this.type = type;
    notifyListeners();
  }
}
