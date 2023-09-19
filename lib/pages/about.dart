import 'package:flutter/material.dart';
import 'package:realtime_taiwan/tabs/settings/list_section.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("關於"),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ListSectionWidget(
                icon: Icon(Icons.language),
                title: "App 首頁",
                trailing: Icon(Icons.open_in_new),
                onTap: () async {
                  await launchUrl(Uri.parse("https://realtime-taiwan.ljcu.cc"));
                }),
            ListSectionWidget(
                icon: Icon(Icons.language),
                title: "資料集歸依宣告",
                trailing: Icon(Icons.open_in_new),
                onTap: () async {
                  await launchUrl(
                      Uri.parse("https://realtime-taiwan.ljcu.cc#/data"));
                }),
            ListSectionWidget(
              icon: Icon(Icons.file_open),
              title: "軟體依賴授權宣告",
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const LicensePage(
                        applicationVersion: "1.0.0",
                        applicationLegalese: "Made with love from the_ITWolf",
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
