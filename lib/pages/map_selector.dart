import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/location.dart';
import 'package:realtime_taiwan/data/map_source.dart';
import 'package:latlong2/latlong.dart';

class MapSelectorPage extends StatefulWidget {
  const MapSelectorPage({super.key});

  static open(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MapSelectorPage();
    }));
  }

  @override
  State<MapSelectorPage> createState() => _MapSelectorPageState();
}

class _MapSelectorPageState extends State<MapSelectorPage> {
  late MapTileOption groupValue;
  double _zoom = 9;
  LatLng _center = defaultLoc;

  @override
  void initState() {
    super.initState();

    final model = Provider.of<MapSourceModel>(context, listen: false);
    groupValue = model.type ?? MapTileOptions[0];
  }

  _onMapEvent(MapEvent p0) {
    setState(() {
      _center = p0.center;
      _zoom = p0.zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MapSourceModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("選擇地圖"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      center: _center,
                      zoom: _zoom,
                      onMapEvent: _onMapEvent,
                    ),
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onPrimaryContainer,
                          BlendMode.hue,
                        ),
                        child: TileLayer(
                          urlTemplate: model.type.url,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  ...MapTileOptions.map((element) {
                    if (element.customBuilder != null)
                      return element.customBuilder!;

                    return RadioListTile(
                      title: Text(element.name),
                      subtitle: element.subtitle,
                      value: element,
                      groupValue: groupValue,
                      onChanged: (value) {
                        setState(() {
                          groupValue = value!;
                          final model = Provider.of<MapSourceModel>(context,
                              listen: false)
                            ..setType(element);
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
