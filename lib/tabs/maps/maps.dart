// flutter inbuilt packages
import 'package:flutter/material.dart';
import 'dart:math';

// maps packages
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

// in-app packages
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/data/location.dart';
import 'package:realtime_taiwan/data/map_source.dart';
import 'package:realtime_taiwan/tabs/maps/maps_display.dart';
import 'package:realtime_taiwan/tabs/maps/streaming.dart';

import "package:provider/provider.dart";
import 'package:url_launcher/url_launcher_string.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<CCTVItem>? list;

  final LocationModel _locationModel = LocationModel();

  @override
  void initState() {
    super.initState();

    // load XML
    setState(() {
      list = cctvList.all;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapDisplayWidget(
          locationModel: _locationModel,
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
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }
}
