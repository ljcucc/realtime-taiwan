import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/data/lang.dart';
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
    if (cctvList.isEmpty) {
      final xmlString = await getOpendataCCTV(context);
      // compute((xmlString) => cctvList.loadXML(xmlString), xmlString);
      await for (final index in cctvList.loadXML(xmlString)) {
        yield lang(context).loading_db_num(index);
      }
    }
    yield lang(context).loading_done;
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
            onPressed: () {
              _mapDisplayController.notifyListeners();
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
    return ChangeNotifierProvider.value(
      value: _mapDisplayController,
      child: loading ? Container() : layout,
    );
  }
}
