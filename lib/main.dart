import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/data/location.dart';
import 'package:realtime_taiwan/data/map_source.dart';
import 'package:realtime_taiwan/layout.dart';
import 'package:realtime_taiwan/pages/loading.dart';

import 'package:realtime_taiwan/tabs/maps/maps.dart';
import 'package:realtime_taiwan/tabs/maps/maps_display.dart';
import 'package:realtime_taiwan/tabs/saved.dart';
import 'package:realtime_taiwan/tabs/settings/settings.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
  // database.dispose();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MapSourceModel())
      ],
      child: MaterialApp(
        title: 'Realtime Taiwan',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(0, 26, 205, 195)),
          useMaterial3: true,
        ),
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  bool loading = true;
  final MapDisplayController _mapDisplayController = MapDisplayController();
  final LocationModel locationModel = LocationModel();

  @override
  void initState() {
    super.initState();

    print("starting...");
    initScreen();
  }

  Stream<String?> onLoading() async* {
    print("initDatabase...");
    await initDatabase();
    yield lang(context).loading_db;
    final databasePath = appPath;

    if (cctvList.isEmpty) {
      final xmlString = await getOpendataCCTV();
      await Isolate.run(() async {
        print("folder: ${databasePath}");
        final cctvl = await getCctvList(databasePath);
        await cctvl.loadXML(xmlString);
      });
    }
    cctvList = await getCctvList(databasePath);
    yield lang(context).loading_done;
  }

  void setupDatabase() async {
    // compute((xmlString) => cctvList.loadXML(xmlString), xmlString);
    // yield lang(context).loading_db_num(index);
  }

  void initScreen() {
    Future.delayed(Duration(seconds: 0), () async {
      // push loading screen with no animation
      await Navigator.of(context).push(PageRouteBuilder(
        transitionDuration: Duration.zero, // no animation with zero duration
        reverseTransitionDuration:
            Duration(milliseconds: 200), // and exit with animation
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        pageBuilder: (context, animation1, animation2) {
          return LoadingPage(
            onLoading: onLoading,
          );
        },
      ));
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = BasicLayout(
      navigations: [
        BasicNavigation(
          selectedIcon: Icon(Icons.map),
          icon: Icon(Icons.map_outlined),
          label: lang(context).tab_map,
          body: MapsPage(),
          fab: FloatingActionButton(
            child: Icon(Icons.my_location),
            onPressed: () async {
              if (locationModel.permissionGranted) return;

              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Location Access"),
                  content: Text(
                      "You're using a function that's need location access,which will display your current location on screen (map).to continue use this optional feature, please press Allow to continue. (currently because of flutter plugin, this feature only works with percise location)"),
                  actions: [
                    TextButton(
                      child: const Text('Allow'),
                      onPressed: () async {
                        await locationModel.initLocation();
                        _mapDisplayController.notifyListeners();
                        Navigator.of(context).pop();
                      },
                    ),
                    FilledButton(
                      child: const Text("Reject"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        BasicNavigation(
          selectedIcon: Icon(Icons.bookmark),
          icon: Icon(Icons.bookmark_outline),
          label: lang(context).tab_saved,
          body: SavedPage(),
        ),
        BasicNavigation(
          selectedIcon: Icon(Icons.settings),
          icon: Icon(Icons.settings_outlined),
          label: lang(context).tab_settings,
          body: SettingsPage(),
        )
      ],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _mapDisplayController),
        ChangeNotifierProvider.value(value: locationModel),
      ],
      child: loading ? Container() : layout,
    );
  }
}
