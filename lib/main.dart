import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:realtime_taiwan/cctv.dart';
import 'package:realtime_taiwan/streaming.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '台灣即時影像',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(0, 238, 255, 6)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '台灣即時影像'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16).copyWith(top: 0),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          child: StreamingPage(title: e['surveillancedescription']!, info: e),
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
    return Scaffold(
      // appBar: AppBar(
      //   // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: FlutterMap(
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
                BlendMode.hue),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'search',
        child: const Icon(Icons.search),
      ),
    );
  }
}
