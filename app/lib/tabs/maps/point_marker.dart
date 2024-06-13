// flutter inbuilt packages

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:realtime_taiwan/tabs/maps/maps.dart';

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
                boxShadow: [],
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
