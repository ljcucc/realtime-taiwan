import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/pages/loading.dart';

import 'package:realtime_taiwan/tabs/maps/maps.dart';
import 'package:realtime_taiwan/tabs/saved.dart';
import 'package:realtime_taiwan/tabs/settings/settings.dart';

void main() {
  runApp(const MyApp());
  // database.dispose();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Taiwan',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(0, 26, 205, 195)),
        useMaterial3: true,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final actions = {
    {
      'selectedIcon': Icon(Icons.map),
      'icon': Icon(Icons.map_outlined),
      'label': '地圖'
    },
    {
      'selectedIcon': Icon(Icons.bookmark),
      'icon': Icon(Icons.bookmark_outline),
      'label': '儲存',
    },
    {
      'selectedIcon': Icon(Icons.settings),
      'icon': Icon(Icons.settings_outlined),
      'label': '設定',
    }
  };

  int currentPageIndex = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    print("starting...");
    initScreen();
  }

  Future<void> onLoading() async {
    print("initDatabase...");
    await initDatabase();
    print("fetching database data...");
    if (cctvList.isEmpty) {
      final xmlString = await getOpendataCCTV(context);
      // compute((xmlString) => cctvList.loadXML(xmlString), xmlString);
      await cctvList.loadXML(xmlString);
      print("length of db: ${cctvList.length}");
    }
    print("done");
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

  bool isPhone(context) {
    final platform = Theme.of(context).platform;
    final isDesktop = [
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.windows
    ].contains(platform);
    final deviceWidth = MediaQuery.of(context).size.width;
    final isPhone = (isDesktop && (deviceWidth < 800)) ||
        (!isDesktop && (deviceWidth < 1000));
    return isPhone;
  }

  Widget switchPage(index) {
    switch (index) {
      case 0:
        return MapsPage();
      case 1:
        return SavedPage();
      case 2:
        return SettingsPage();
    }

    return Container();
  }

  Widget? switchFAB(int index) {
    switch (index) {
      case 0:
        return FloatingActionButton(
          child: Icon(Icons.my_location),
          onPressed: () {},
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final navigationRail = NavigationRail(
      groupAlignment: 0,
      destinations: [
        ...actions.map((e) {
          return NavigationRailDestination(
            icon: e['icon'] as Icon,
            label: Text(e['label'] as String),
            selectedIcon: e['selectedIcon'] as Icon,
          );
        }).toList(),
      ],
      labelType: NavigationRailLabelType.all,
      selectedIndex: currentPageIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentPageIndex = index;
        });
      },
    );
    final buttomNavigationBar = NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      selectedIndex: currentPageIndex,
      destinations: <Widget>[
        ...actions.map((e) {
          return NavigationDestination(
            icon: e['icon'] as Icon,
            label: e['label'] as String,
            selectedIcon: e['selectedIcon'] as Icon,
          );
        }).toList(),
      ],
    );

    return Scaffold(
      body: loading
          ? Container()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                !isPhone(context) ? navigationRail : Container(),
                Expanded(
                  child: switchPage(currentPageIndex),
                )
              ],
            ),
      bottomNavigationBar: isPhone(context) ? buttomNavigationBar : null,
      floatingActionButton: switchFAB(currentPageIndex),
    );
  }
}
