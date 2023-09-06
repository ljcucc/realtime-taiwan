// flutter inbuilt packages
import 'package:flutter/material.dart';
import 'dart:math';

// maps packages
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// in-app packages
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/tabs/maps/streaming.dart';

class PointMarker extends StatefulWidget {
  final double zoomLevel;
  final VoidCallback onTap;
  const PointMarker({
    super.key,
    required this.zoomLevel,
    required this.onTap,
  });

  @override
  State<PointMarker> createState() => _PointMarkerState();
}

class _PointMarkerState extends State<PointMarker> {
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() {
        onHover = true;
      }),
      onExit: (event) => setState(() {
        onHover = false;
      }),
      onHover: (event) => setState(() {
        onHover = true;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: onHover ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                boxShadow: [
                  // BoxShadow(
                  //   color: Colors.black.withOpacity(.35),
                  //   blurRadius: onHover ? 5 : 0,
                  //   spreadRadius: 0,
                  // )
                ],
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: widget.zoomLevel * 0.4,
                ),
                color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  List<CCTVItem>? list;
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
      // list = CCTVListParser(str).list;
      list = cctvList.all;
      print("hello");
      print(list!.length);
    });
  }

  setCurZoom(double zoom) async {
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      curZoom = zoom;
    });
  }

  openStream(CCTVItem item) async {
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
          initialChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              child: StreamingPageBottomSheet(
                controller: scrollController,
                item: item,
              ),
            );
          },
        );
      },
    );
  }

  generateMarks(context) {
    final result = (list ?? [])
        .map((e) {
          if (curZoom < 9) {
            return null;
          }

          // if (curZoom < 15) {
          return Marker(
            point: e.loc,
            width: (pow(curZoom, 1.35) as double),
            height: (pow(curZoom, 1.35) as double),
            builder: (context) => PointMarker(
              zoomLevel: curZoom,
              onTap: () {
                openStream(e);
              },
            ),
          );
          // }
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
            Theme.of(context).colorScheme.onPrimaryContainer,
            BlendMode.hue,
          ),
          child: /*ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation),
              child:*/
              TileLayer(
            urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
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
