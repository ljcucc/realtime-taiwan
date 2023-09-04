import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:realtime_taiwan/cctv.dart';
import 'package:webview_flutter/webview_flutter.dart';

void PlatformVideoWidget() {
  if (true) {}
}

class StreamingPage extends StatefulWidget {
  final Map<String, String> info;

  const StreamingPage({
    super.key,
    required this.info,
  });

  @override
  State<StreamingPage> createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingPage> {
  String time = DateTime.now().millisecondsSinceEpoch.toString();
  // late final WebViewController controller;
  List<String> urlList = [];
  String? imageBase64;

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero, () {
    //   var platform = Theme.of(context).platform;
    //   if (platform == TargetPlatform.android || platform == TargetPlatform.iOS)
    //     controller = WebViewController()
    //       ..loadRequest(Uri.parse(widget.info['videostreamurl']!));
    // });
    timer();
  }

  timer() async {
    while (true) {
      await Future.delayed(Duration(seconds: 30));
      print("update");

      setState(() {
        // imageBase64 = base64;
        time = DateTime.now().millisecondsSinceEpoch.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;
    var videoWidget = Padding(
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

    return Padding(
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
    );
  }
}

class StreamingPageSideSheet extends StatelessWidget {
  final Map<String, String> info;
  const StreamingPageSideSheet({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(info['roadname']!),
              Text(
                info['locationmile']!,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ],
          ),
        ),
      ),
      body: StreamingPage(
        info: info,
      ),
    );
  }
}

class StreamingPageBottomSheet extends StatelessWidget {
  final Map<String, String> info;
  final ScrollController controller;
  const StreamingPageBottomSheet(
      {super.key, required this.info, required this.controller});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return Padding(
      padding: EdgeInsets.all(16).copyWith(
        top:
            platform == TargetPlatform.android || platform == TargetPlatform.iOS
                ? 0
                : null,
      ),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info['roadname']!,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        info['locationmile']!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
              StreamingPage(info: info),
            ],
          ),
        ),
      ),
    );
  }
}
