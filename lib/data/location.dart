import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class LocationModel extends ChangeNotifier {
  Location location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LatLng? _geo;

  LatLng get geo => _geo ?? LatLng(23.5, 120.9738819);

  initLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    print("application allow");
    notifyListeners();

    location.onLocationChanged.listen((LocationData locationData) {
      double lat = locationData.latitude!, lon = locationData.longitude!;
      _geo = LatLng(lat, lon);
      notifyListeners();
    });
  }
}
