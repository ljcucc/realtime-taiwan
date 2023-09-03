import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:realtime_taiwan/cctv.dart';

class StreamImage extends StatefulWidget {
  final String url;
  const StreamImage({super.key, required this.url});

  @override
  State<StreamImage> createState() => _StreamImageState();
}

class _StreamImageState extends State<StreamImage> {
  ImageStreaming? streaming;
  Uint8List? cached;

  @override
  void initState() {
    super.initState();

    imageStream();
  }

  imageStream() async {
    streaming = ImageStreaming(
      url: widget.url,
      onImage: (List<int> buffer) {
        print("on image");
        setState(() {
          cached = Uint8List.fromList(buffer);
        });
      },
    );
    streaming!.send();
  }

  @override
  Widget build(BuildContext context) {
    if (cached != null) return Image.memory(cached!);
    return Container();
  }
}

class StreamingPage extends StatefulWidget {
  final String title;
  final Map<String, String> info;
  const StreamingPage({super.key, required this.title, required this.info});

  @override
  State<StreamingPage> createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingPage> {
  String time = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints.expand(),
          child: StreamImage(
            url: widget.info['videostreamurl']!,
          ),
        ),
      ),
    );
  }
}
