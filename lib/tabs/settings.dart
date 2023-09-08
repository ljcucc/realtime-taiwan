import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget SettingsSection({
    required String title,
    String? subtitle,
    required Icon icon,
    Widget? trailing,
    Color? color,
    EdgeInsets? padding,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Builder(builder: (context) {
      return Container(
        padding: EdgeInsets.only(bottom: 10.0),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          onTap: onTap ?? () {},
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: icon,
              ),
              title: Text(
                title,
              ),
              subtitle: subtitle != null ? Text(subtitle) : null,
              trailing: trailing,
            ),
          ),
        ),
      );
    });
  }

  // Widget AboutSection(){
  //   return
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text("設定", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 32),
                Container(
                  // padding: const EdgeInsets.all(16),
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      SettingsSection(
                        title: "餵飼料",
                        subtitle: "如果覺得這個app很讚，不妨投餵點牧草給碼農吧！",
                        icon: Icon(Icons.fastfood),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () async {
                          !await launchUrl(Uri.parse("https://google.com"));
                        },
                      ),
                      SizedBox(height: 16),
                      SettingsSection(
                        title: "資料集",
                        subtitle: "資料集已載入",
                        icon: Icon(Icons.donut_large_outlined),
                      ),
                      SettingsSection(
                        title: "地圖",
                        subtitle: "OpenStreetMap",
                        icon: Icon(Icons.map),
                        onTap: () {
                          showDialog<String>(
                            context: context,
                            builder: (context) {
                              return MapSelectorDialog();
                            },
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Divider(),
                      ),
                      SettingsSection(
                        title: "專案頁面",
                        subtitle: "這個應用程式的 Github",
                        icon: Icon(Icons.language),
                        trailing: Icon(Icons.open_in_new),
                        onTap: () async {
                          await launchUrl(Uri.parse(
                              "https://github.com/ljcucc/realtime-taiwan"));
                        },
                      ),
                      // SettingsSection(
                      //   title: "隱私與使用者條款",
                      //   icon: Icon(Icons.policy_outlined),
                      // ),
                      SettingsSection(
                        title: "關於",
                        subtitle: "關於這個應用程式",
                        icon: Icon(Icons.info_outline),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return LicensePage();
                            },
                          ));
                        },
                      ),
                      // SettingsSection(
                      //   title: "開發人員",
                      //   subtitle: "你不該進來這裡的",
                      //   icon: Icon(Icons.code),
                      // ),
                      SettingsSection(
                        title: "重置",
                        subtitle: "萬一程式運作不正常、更新資料",
                        icon: Icon(Icons.dangerous_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
