// flutter inbuilt packages
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

// in-app packages
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/data/location.dart';
import 'package:realtime_taiwan/tabs/maps/maps_display.dart';
import 'package:realtime_taiwan/tabs/maps/streaming.dart';

import "package:provider/provider.dart";
import 'package:url_launcher/url_launcher_string.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with TickerProviderStateMixin {
  List<CCTVItem>? list;
  late final _mapController = AnimatedMapController(vsync: this);

  @override
  void initState() {
    super.initState();

    // load XML
    setState(() {
      list = cctvList.all;
    });
  }

  Future<void> askLocationPermission() async {
    final locationModel = Provider.of<LocationModel>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang(context).location_permission_title),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Text(
            lang(context).location_permission_description,
          ),
        ),
        actions: [
          TextButton(
            child: Text(lang(context).dailog_reject),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FilledButton.tonal(
            child: Text(lang(context).dailog_allow),
            onPressed: () async {
              await locationModel.initLocation();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationModel>(builder: (context, locationModel, _) {
      final colors = Theme.of(context).colorScheme;
      final fab = FloatingActionButton(
        foregroundColor: colors.onTertiaryContainer,
        backgroundColor: colors.tertiaryContainer,
        child: const Icon(Icons.my_location),
        onPressed: () async {
          if (!locationModel.permissionGranted) await askLocationPermission();
          print("start animating...");
          await _mapController.animateTo(dest: locationModel.geo, zoom: 13);
          print("end aniamting...");
        },
      );

      return Stack(
        children: [
          MapDisplayWidget(
            mapController: _mapController.mapController,
            locationModel: locationModel,
            items: list ?? [],
            onTap: (e) {
              openStream(item: e, context: context);
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: TextButton(
              onPressed: () async {
                await launchUrlString("https://realtime-taiwan.ljcu.cc/#/data");
              },
              child: Text(
                lang(context).map_data,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.all(24),
              child: fab,
            ),
          ),
        ],
      );
    });
  }
}
