import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/database.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    initDB();
  }

  initDB() async {
    if (cctvList.isEmpty) {
      final xmlString = await getOpendataCCTV(context);
      // compute((xmlString) => cctvList.loadXML(xmlString), xmlString);
      cctvList.loadXML(xmlString);
      print("length of db: ${cctvList.length}");
    }
    print("done");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 800;
    Widget helpWidget = Positioned(
      bottom: 16,
      right: 16,
      child: IconButton(
        icon: Icon(Icons.info_outline),
        onPressed: () {},
      ),
    );

    if (isPhone) {
      helpWidget = Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Center(
          child: TextButton.icon(
            icon: Icon(Icons.info_outline),
            label: Text("幫助"),
            onPressed: () {},
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            helpWidget,
            Center(
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(maxWidth: 250),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
