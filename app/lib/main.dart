import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/data/location.dart';
import 'package:realtime_taiwan/data/map_source.dart';
import 'package:realtime_taiwan/layout.dart';
import 'package:realtime_taiwan/pages/loading.dart';

import 'package:realtime_taiwan/tabs/maps/maps.dart';
import 'package:realtime_taiwan/tabs/maps/maps_display.dart';
import 'package:realtime_taiwan/tabs/saved/saved.dart';
import 'package:realtime_taiwan/tabs/settings/settings.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(const MyApp());
  // database.dispose();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      final platformBrightness = MediaQuery.of(context).platformBrightness;

      var colorScheme = ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(0, 26, 205, 195),
      );

      if (platformBrightness == Brightness.dark) {
        colorScheme = darkDynamic ?? colorScheme;
      } else {
        colorScheme = lightDynamic ?? colorScheme;
      }

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            final model = MapSourceModel();
            model.init();
            return model;
          }),
          ChangeNotifierProvider(
            create: (context) => BookmarkListModel(
              bookmarkList: bookmarkList,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Realtime Taiwan',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: colorScheme,
            useMaterial3: true,
          ),
          home: const HomePage(),
          debugShowCheckedModeBanner: false,
        ),
      );
    });
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
    Future.delayed(const Duration(seconds: 0), () async {
      // push loading screen with no animation
      await Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: Duration.zero, // no animation with zero duration
          reverseTransitionDuration:
              const Duration(milliseconds: 200), // and exit with animation
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          pageBuilder: (context, animation1, animation2) =>
              LoadingPage(onLoading: onLoading),
        ),
      );

      setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigations = [
      // map tab
      BasicNavigation(
        selectedIcon: const Icon(Icons.map),
        icon: const Icon(Icons.map_outlined),
        label: lang(context).tab_map,
        body: const MapsPage(),
      ),

      // bookmark tab
      BasicNavigation(
        selectedIcon: const Icon(Icons.bookmark),
        icon: const Icon(Icons.bookmark_outline),
        label: lang(context).tab_saved,
        body: const SavedPage(),
      ),

      // settings tab
      BasicNavigation(
        selectedIcon: const Icon(Icons.settings),
        icon: const Icon(Icons.settings_outlined),
        label: lang(context).tab_settings,
        body: const SettingsPage(),
      ),
    ];

    final layout = BasicLayout(navigations: navigations);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locationModel),
      ],
      child: loading ? Container() : layout,
    );
  }
}
