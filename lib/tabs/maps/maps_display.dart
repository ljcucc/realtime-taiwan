import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:realtime_taiwan/data/location.dart'; // device geo location model
import 'package:realtime_taiwan/tabs/maps/point_marker.dart'; // maps markers
import 'package:realtime_taiwan/data/cctv.dart'; // database
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/map_source.dart'; // variable map tile provider
import 'package:latlong2/latlong.dart';

class MapDisplayController extends ChangeNotifier {
  double zoom = 9;
  LatLng? center;

  pos(LatLng you) {
    center = you;
    notifyListeners();
  }
}

class MapDisplayWidget extends StatefulWidget {
  final List<CCTVItem> items;
  final Function(CCTVItem) onTap;
  final LocationModel locationModel;

  const MapDisplayWidget({
    super.key,
    required this.items,
    required this.onTap,
    required this.locationModel,
  });

  @override
  State<MapDisplayWidget> createState() => _MapDisplayWidgetState();
}

class _MapDisplayWidgetState extends State<MapDisplayWidget> {
  double _zoom = 10;
  LatLng? _center;

  final _mapController = MapController();
  MapDisplayController? _mapDisplayController;

  @override
  void initState() {
    super.initState();

    widget.locationModel.initLocation();
    // widget.locationModel.addListener(onLocationMoved);
    _mapDisplayController = context.read<MapDisplayController>();
    _mapDisplayController!.addListener(onLocationPosed);
  }

  onLocationPosed() {
    _mapController.move(widget.locationModel.geo, _zoom);
    _mapController.rotate(0);
  }

  @override
  dispose() {
    super.dispose();

    _mapDisplayController!.removeListener(onLocationPosed);
  }

  onLocationMoved() {
    // if (centerLocked)
    //   _mapController.move(_locationModel.geo, _mapController.zoom);
  }

  listToMarkers(list, context) {
    final List<LatLng> group = [];
    var result = list
        .map((CCTVItem e) {
          final lat = e.loc.latitude;
          final lon = e.loc.longitude;

          if (_zoom < 12) {
            var range = 0.01;
            if (_zoom < 10) {
              range = 0.05;
            }
            if (_zoom < 9) {
              range = 0.1;
            }
            if (_zoom < 7) {
              range = 0.5;
            }
            for (final element in group) {
              if (!(lat < element.latitude - range ||
                  lat > element.latitude + range ||
                  lon < element.longitude - range ||
                  lon > element.longitude + range)) {
                return null;
              }
            }

            group.add(e.loc);
          }

          if (_zoom > 9 && _center != null) {
            var range = 1;

            if (lat < _center!.latitude - range ||
                lat > _center!.latitude + range ||
                lon < _center!.longitude - range ||
                lon > _center!.longitude + range) {
              return null;
            }
          }

          double size = pow(_zoom, 1.35) as double;

          return Marker(
            point: e.loc,
            width: size,
            height: size,
            builder: (context) => PointMarker(
              zoomLevel: _zoom,
              onTap: () {
                widget.onTap(e);
              },
            ),
          );
        })
        .toList()
        .where((e) => e != null);
    return result;
  }

  onMapEvent(MapEvent p0) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // sync zoom value of map
    setState(() {
      _zoom = p0.zoom;
      _center = p0.center;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: widget.locationModel.geo,
        zoom: 10,
        maxZoom: 18,
        onMapEvent: onMapEvent,
      ),
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onPrimaryContainer,
            BlendMode.hue,
          ),
          child: Consumer<MapSourceModel>(builder: (context, model, child) {
            var url = MapTileOptions[0].url;
            if (model.type != null) {
              url = model.type!.url;
            }
            return TileLayer(
              urlTemplate: url,
              userAgentPackageName: 'com.example.app',
            );
          }),
        ),
        ListenableBuilder(
          listenable: widget.locationModel,
          builder: (context, child) {
            return MarkerLayer(
              markers: [
                Marker(
                  point: widget.locationModel.geo!,
                  builder: (BuildContext context) {
                    return Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onPrimary,
                          width: 5,
                        ),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        MarkerLayer(
          markers: [
            ...listToMarkers(widget.items, context),
          ],
        ),
      ],
    );
  }
}
