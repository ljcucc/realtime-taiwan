import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:realtime_taiwan/cctv.dart';

class StreamingPage extends StatefulWidget {
  final String title;
  final Map<String, String> info;
  const StreamingPage({super.key, required this.title, required this.info});

  @override
  State<StreamingPage> createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingPage> {
  String time = DateTime.now().millisecondsSinceEpoch.toString();
  StreamImage? image;
  List<int> imageBuffer = [];
  Uint8List? imageCache;

  @override
  void initState() {
    super.initState();

    var streamImage = StreamImage(url: widget.info['videostreamurl']!);
    image = streamImage;
    sendRequest();
  }

  sendRequest() async {
    await image!.send();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(time),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints.expand(),
          child: (image?.respone != null)
              ? StreamBuilder<List<int>>(
                  stream: image!.respone,
                  builder: (context, snapshot) {
                    print("realtime!");
                    if (snapshot.data!.length > 1000) {
                      imageBuffer.addAll(snapshot.data!);
                    } else {
                      print("cached");
                      imageCache = Uint8List.fromList(imageBuffer);
                      imageBuffer = [];
                    }
                    if (imageCache == null) return Container();
                    return Image.memory(
                      imageCache!,
                      fit: BoxFit.cover,
                    );
                  })
              : Container(),
        ),
      ),
    );
  }
}
