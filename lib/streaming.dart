import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:realtime_taiwan/cctv.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'dart:io' show Platform;

void PlatformVideoWidget() {
  if (true) {}
}

class StreamingPage extends StatefulWidget {
  final String title;
  final ScrollController scrollController;
  final Map<String, String> info;

  const StreamingPage({
    super.key,
    required this.title,
    required this.info,
    required this.scrollController,
  });

  @override
  State<StreamingPage> createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingPage> {
  String time = DateTime.now().millisecondsSinceEpoch.toString();
  late final WebViewController controller;
  List<String> urlList = [];
  String? imageBase64;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS)
      controller = WebViewController()
        ..loadRequest(Uri.parse(widget.info['videostreamurl']!));
    timer();
  }

  timer() async {
    while (true) {
      await Future.delayed(Duration(seconds: 30));
      print("update");

      // final url = widget.info['videoimageurl']!;
      // final base64 = await fetchImgBase64(url + "?${time}");
      // print("fetched");
      setState(() {
        // imageBase64 = base64;
        time = DateTime.now().millisecondsSinceEpoch.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // var base64Img = imageBase64 != null
    //     ? Image.memory(
    //         base64Decode(imageBase64!),
    //         fit: BoxFit.cover,
    //         gaplessPlayback: true,
    //       )
    //     : Container();

    var videoWidget = Platform.isAndroid && Platform.isIOS
        ? WebViewWidget(
            controller: controller,
          )
        : Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Container(
                // height: 200,
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 1.7,
                  child: Image.network(
                    "${widget.info['videoimageurl']!}?${time}",
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: Align(
          alignment: Alignment.center,
          child: IconButton.filledTonal(
            iconSize: 24,
            // padding: EdgeInsets.all(16),
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Align(
          alignment: Alignment.topRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(widget.info['roadname']!),
              Text(
                widget.info['locationmile']!,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                videoWidget,
                // Text(time),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
