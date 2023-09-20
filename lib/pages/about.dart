import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/tabs/settings/list_section.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(lang(context).about_title),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ListSectionWidget(
                icon: Icon(Icons.language),
                title: Text(lang(context).about_apphomepage),
                trailing: Icon(Icons.open_in_new),
                onTap: () async {
                  await launchUrl(Uri.parse("https://realtime-taiwan.ljcu.cc"));
                }),
            ListSectionWidget(
                icon: Icon(Icons.language),
                title: Text(lang(context).about_dataattr),
                trailing: Icon(Icons.open_in_new),
                onTap: () async {
                  await launchUrl(
                      Uri.parse("https://realtime-taiwan.ljcu.cc#/data"));
                }),
            ListSectionWidget(
              icon: Icon(Icons.file_open),
              title: Text(lang(context).about_license),
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
