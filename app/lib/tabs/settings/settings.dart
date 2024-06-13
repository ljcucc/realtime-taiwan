import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/data/map_source.dart';
import 'package:realtime_taiwan/pages/about.dart';
import 'package:realtime_taiwan/tabs/settings/list_section.dart';
import 'package:realtime_taiwan/pages/map_selector.dart';
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
    final settingsOptions = [
      Consumer<MapSourceModel>(builder: (context, model, child) {
        var name = MapTileOptions[0].name;
        if (model.type != null) name = model.type!.name;
        return ListSectionWidget(
          title: Text(lang(context).settings_map),
          subtitle: name,
          icon: Icon(Icons.map),
          onTap: () {
            MapSelectorPage.open(context);
          },
        );
      }),
      ListSectionWidget(
        title: Text(lang(context).settings_about),
        subtitle: Text(lang(context).settings_about_subtitle),
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
        title: Text(lang(context).settings_sourcecode),
        subtitle: Text(lang(context).settings_sourcecode_subtitle),
        icon: Icon(Icons.language),
        trailing: Icon(Icons.open_in_new),
        onTap: () async {
          await launchUrl(
              Uri.parse("https://github.com/ljcucc/realtime-taiwan"));
        },
      ),
    ];

    return SafeArea(
      child: Center(
        child: Container(
          height: double.infinity,
          constraints: BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(lang(context).tab_settings,
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 32),
                  Container(
                    // padding: const EdgeInsets.all(16),
                    alignment: Alignment.topLeft,
                    child: Column(
                      children: settingsOptions,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
