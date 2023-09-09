import 'package:flutter/material.dart';

enum MapTileOptions {
  OpenStreetMap,
  GoogleMap,
}

class MapSelectorDialog extends StatefulWidget {
  const MapSelectorDialog({super.key});

  @override
  State<MapSelectorDialog> createState() => _MapSelectorDialogState();
}

class _MapSelectorDialogState extends State<MapSelectorDialog> {
  MapTileOptions groupValue = MapTileOptions.GoogleMap;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("選擇地圖"),
      scrollable: true,
      content: Column(
        children: [
          RadioListTile(
            title: Text("Google Maps"),
            value: MapTileOptions.GoogleMap,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
          RadioListTile(
            title: Text("Open Street Map"),
            value: MapTileOptions.OpenStreetMap,
            groupValue: groupValue,
            onChanged: (value) {
              setState(() {
                groupValue = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("取消"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("選擇"),
        ),
      ],
    );
  }
}
