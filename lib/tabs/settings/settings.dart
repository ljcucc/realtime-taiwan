import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/map_source.dart';
import 'package:realtime_taiwan/pages/about.dart';
import 'package:realtime_taiwan/tabs/settings/list_section.dart';
import 'package:realtime_taiwan/tabs/settings/map_selector_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ResetAllDialog extends StatelessWidget {
  const ResetAllDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text("重置"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("在重置應用程式的過程，以下資料都會被清除"),
          SizedBox(
            height: 8,
          ),
          Divider(),
          ListTile(
            title: Text("書籤資料"),
            subtitle: Text("所有你已儲存的地點，記得在重置之前匯出。"),
            // leading: Icon(Icons.bookmark),
          ),
          ListTile(
            title: Text("快取資料"),
            subtitle: Text("所有你已下載的快取資料都將會被清除，如果應用程式沒有正常運作可以試試看。"),
            // leading: Icon(Icons.storage),
          ),
          Divider(),
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
          child: Text("確定"),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                      Consumer<MapSourceModel>(
                          builder: (context, model, child) {
                        var name = MapTileOptions[0].name;
                        if (model.type != null) name = model.type!.name;
                        return ListSectionWidget(
                          title: "地圖",
                          subtitle: name,
                          icon: Icon(Icons.map),
                          onTap: () {
                            showDialog<String>(
                              context: context,
                              builder: (context) {
                                return MapSelectorDialog();
                              },
                            );
                          },
                        );
                      }),
                      ListSectionWidget(
                        title: "關於",
                        subtitle: "關於這個應用程式",
                        icon: Icon(Icons.info_outline),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return const AboutPage();
                            }),
                          );
                        },
                      ),
                      ListSectionWidget(
                        title: "原始碼",
                        subtitle: "這個應用程式在 Github 的原始程式碼",
                        icon: Icon(Icons.language),
                        trailing: Icon(Icons.open_in_new),
                        onTap: () async {
                          await launchUrl(Uri.parse(
                              "https://github.com/ljcucc/realtime-taiwan"));
                        },
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
