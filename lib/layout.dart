import 'package:flutter/material.dart';

class BasicNavigation {
  final Icon selectedIcon;
  final Icon icon;
  final String label;
  final Widget? fab;
  final Widget body;

  const BasicNavigation({
    required this.selectedIcon,
    required this.icon,
    required this.label,
    required this.body,
    this.fab,
  });
}

class BasicLayout extends StatefulWidget {
  final List<BasicNavigation> navigations;

  const BasicLayout({
    super.key,
    required this.navigations,
  });

  @override
  State<BasicLayout> createState() => _BasicLayoutState();
}

class _BasicLayoutState extends State<BasicLayout> {
  int currentPageIndex = 0;

  navigationRail() {
    return NavigationRail(
      groupAlignment: 0,
      destinations: [
        ...widget.navigations.map((e) {
          return NavigationRailDestination(
            icon: e.icon,
            label: Text(e.label),
            selectedIcon: e.selectedIcon,
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
  }

  buttomNavigationBar() {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
        });
      },
      selectedIndex: currentPageIndex,
      destinations: <Widget>[
        ...widget.navigations.map((e) {
          return NavigationDestination(
            icon: e.icon,
            label: e.label,
            selectedIcon: e.selectedIcon,
          );
        }).toList(),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          !isPhone(context) ? navigationRail() : Container(),
          Expanded(
            child: widget.navigations[currentPageIndex].body!,
          )
        ],
      ),
      bottomNavigationBar: isPhone(context) ? buttomNavigationBar() : null,
      floatingActionButton: widget.navigations[currentPageIndex].fab,
    );
  }
}
