import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const storeKey = "map-tile-index";
  SharedPreferences? prefs;
  int? index;

  Future<void> init() async {
    if (prefs != null) return;
    prefs = await SharedPreferences.getInstance();
  }

  MapTileOption get type {
    if (prefs == null) {
      init();
    }
    index ??= prefs?.getInt('map-tile-index') ?? 0;
    return MapTileOptions[index!];
  }

  void setType(MapTileOption t) async {
    index = MapTileOptions.indexOf(t);
    if (index! < 0) {
      index = 0;
    }

    await prefs?.setInt('map-tile-index', index!);
    notifyListeners();
  }
}
