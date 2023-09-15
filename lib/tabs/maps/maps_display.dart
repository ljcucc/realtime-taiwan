import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:realtime_taiwan/data/location.dart'; // device geo location model
import 'package:realtime_taiwan/tabs/maps/point_marker.dart'; // maps markers
import 'package:realtime_taiwan/data/cctv.dart'; // database
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/map_source.dart'; // variable map tile provider

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
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();

    widget.locationModel.initLocation();
    // widget.locationModel.addListener(onLocationMoved);
  }

  onLocationMoved() {
    // if (centerLocked)
    //   _mapController.move(_locationModel.geo, _mapController.zoom);
  }

  listToMarkers(list, context) {
    var result = list
        .map((e) {
          if (_zoom < 9) return null;

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

  onMapEvent(p0) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // sync zoom value of map
    setState(() {
      _zoom = p0.zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
            return TileLayer(
              urlTemplate: model.source ??
                  'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
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
