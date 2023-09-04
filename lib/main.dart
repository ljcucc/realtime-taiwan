import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:realtime_taiwan/cctv.dart';
import 'package:realtime_taiwan/tabs/maps/streaming.dart';

import 'package:realtime_taiwan/tabs/maps/maps.dart';
import 'package:realtime_taiwan/tabs/saved.dart';
import 'package:realtime_taiwan/tabs/settings.dart';

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
      home: HomePage(),
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
      leading: Container(),
      trailing: Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Spacer(),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.heart_broken_rounded),
              ),
            ],
          ),
        ),
      ),
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
      body: Row(
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
