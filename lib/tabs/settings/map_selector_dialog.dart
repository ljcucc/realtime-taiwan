import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/map_source.dart';

class MapSelectorDialog extends StatefulWidget {
  const MapSelectorDialog({super.key});

  @override
  State<MapSelectorDialog> createState() => _MapSelectorDialogState();
}

class _MapSelectorDialogState extends State<MapSelectorDialog> {
  late MapTileOption groupValue;
  @override
  void initState() {
    super.initState();

    final model = Provider.of<MapSourceModel>(context, listen: false);
    groupValue = model.type ?? MapTileOptions[0];
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MapSourceModel>(context, listen: false);

    return AlertDialog(
      title: Text("選擇地圖"),
      scrollable: true,
      content: Column(
        children: [
          ...MapTileOptions.map((element) {
            return RadioListTile(
              title: Text(element.name),
              value: element,
              groupValue: groupValue,
              onChanged: (value) {
                setState(() {
                  groupValue = value!;
                  final model =
                      Provider.of<MapSourceModel>(context, listen: false)
                        ..setType(element);
                });
              },
            );
          }),
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
