// flutter inbuilt packages
import 'package:flutter/material.dart';
import 'dart:math';

// maps packages
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// in-app packages
import 'package:realtime_taiwan/cctv.dart';
import 'package:realtime_taiwan/streaming.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  CCTVList? list;
  double curZoom = 10;
  @override
  void initState() {
    super.initState();

    loadXML();
  }

  loadXML() async {
    final str = await DefaultAssetBundle.of(context)
        .loadString("assets/opendataCCTVs.xml");
    setState(() {
      list = CCTVList(str);
    });
  }

  setCurZoom(double zoom) async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      curZoom = zoom;
    });
  }

  openStream(e) async {
    final platform = Theme.of(context).platform;
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      isDismissible: true,
      showDragHandle:
          platform == TargetPlatform.android || platform == TargetPlatform.iOS,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.9,
          minChildSize: 0.35,
          initialChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              child: StreamingPageBottomSheet(
                controller: scrollController,
                info: e,
              ),
            );
          },
        );
      },
    );
  }

  generateMarks(context) {
    final result = (list?.list ?? [])
        .map((e) {
          final lat = double.parse(e['positionlat']!);
          final lon = double.parse(e['positionlon']!);

          if (curZoom < 9) {
            return null;
          }

          // if (curZoom < 15) {
          return Marker(
            point: LatLng(lat, lon),
            width: (pow(curZoom, 1.35) as double),
            height: (pow(curZoom, 1.35) as double),
            builder: (context) => GestureDetector(
              onTap: () {
                openStream(e);
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: curZoom * 0.4,
                    ),
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
          );
          // }

          return Marker(
            point: LatLng(lat, lon),
            width: 5 * curZoom,
            height: 5 * curZoom,
            builder: (context) => IconButton.filled(
              icon: const Icon(
                Icons.camera,
              ),
              onPressed: () {
                openStream(e);
              },
            ),
          );
        })
        .toList()
        .where((e) => e != null);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(23.5, 120.9738819),
        zoom: 10,
        maxZoom: 18,
        onMapEvent: (p0) {
          setCurZoom(p0.zoom);
        },
      ),
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onPrimaryContainer, BlendMode.hue),
          child: /*ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation),
              child:*/
              TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            //),
          ),
        ),
        MarkerLayer(
          markers: [
            ...generateMarks(context),
          ],
        ),
      ],
    );
  }
}
