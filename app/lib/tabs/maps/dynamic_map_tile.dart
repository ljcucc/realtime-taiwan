import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/map_source.dart';

class DynamicMapTile extends StatelessWidget {
  const DynamicMapTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.surface,
        BlendMode.hue,
      ),
      child: ColorFiltered(
        // Auto adjutt brightness of platform by nagtive the image
        colorFilter: ColorFilter.mode(
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          BlendMode.difference,
        ),
        child: Consumer<MapSourceModel>(builder: (context, model, child) {
          var url = MapTileOptions[0].url;
          if (model.type != null) {
            url = model.type!.url;
          }
          return TileLayer(
            urlTemplate: url,
            userAgentPackageName: 'com.example.app',
          );
        }),
      ),
    );
  }
}
