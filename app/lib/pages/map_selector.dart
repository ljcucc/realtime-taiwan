import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/data/location.dart';
import 'package:realtime_taiwan/data/map_source.dart';
import 'package:latlong2/latlong.dart';
import 'package:realtime_taiwan/tabs/maps/dynamic_map_tile.dart';

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

  _onMapEvent(MapEvent p0) async {
    await Future.delayed(const Duration(milliseconds: 0));

    setState(() {
      _center = p0.center;
      _zoom = p0.zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final map = FlutterMap(
      options: MapOptions(
        center: _center,
        zoom: _zoom,
        onMapEvent: _onMapEvent,
      ),
      children: [
        const DynamicMapTile(),
      ],
    );

    final mapDisp = Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: map,
    );

    final options = Column(
      children: [
        ...MapTileOptions.map((element) {
          if (element.customBuilder != null) return element.customBuilder!;

          return RadioListTile(
            title: element.name,
            subtitle: element.description,
            value: element,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
                final model =
                    Provider.of<MapSourceModel>(context, listen: false)
                      ..setType(element);
              });
            },
          );
        }),
      ],
    );

    final layout = Builder(builder: (context) {
      final width = MediaQuery.of(context).size.width;
      if (width > 800) {
        return Row(children: [
          Expanded(child: mapDisp),
          const Gap(16),
          SizedBox(
            width: 400,
            child: options,
          ),
        ]);
      }
      return Column(
        children: [
          Expanded(child: mapDisp),
          const Gap(16),
          options,
        ],
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(lang(context).mapselector_title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: layout,
        ),
      ),
    );
  }
}
