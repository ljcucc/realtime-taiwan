import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:http/http.dart' as http;

class MultipartStreamingController extends ChangeNotifier {
  bool isStreaming;

  MultipartStreamingController({this.isStreaming = true});

  void resume() {
    isStreaming = true;
    notifyListeners();
  }

  void pause() {
    isStreaming = false;
    notifyListeners();
  }
}

class MultipartStream extends StatefulWidget {
  final MultipartStreamingController controller;
  final CCTVInfo info;

  const MultipartStream({
    super.key,
    required this.info,
    required this.controller,
  });

  @override
  State<MultipartStream> createState() => _StreamingPageState();
}

class _StreamingPageState extends State<MultipartStream> {
  List<int> buffer = [];
  http.Client? client;

  StreamSubscription<MimeMultipart>? streaming;

  // credit: https://stackoverflow.com/questions/72294203/how-to-parse-an-http-multipart-mixed-response-in-dart-flutter
  Future<void> loadStream() async {
    client = http.Client();

    final url = widget.info.videoStreamUrl;
    final rq = http.Request("GET", Uri.parse(url));
    final sr = await client!.send(rq);

    // Generate REGEX to get boundary from content-type header
    final boundaryget = RegExp('boundary=(.+)');
    final contentType = sr!.headers["content-type"].toString();

    // Get the boundary
    final match = boundaryget.firstMatch(contentType);
    final boundary = match?.group(1) as String;

    final mm = MimeMultipartTransformer(boundary);
    streaming = mm.bind(sr!.stream).listen(
      (res) async {
        // print("header: ${res.headers}");
        // print("length: ${res.headers["content-length"]}");

        List<int> image = [];
        for (var bytes in (await res.toList())) {
          image.addAll(bytes);
        }
        buffer = image;
        // print("file actual size: ${image.length}");

        setState(() {});
      },
      onDone: () {
        print("Stream done!");
        loadStream();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    print("New stream");
    loadStream();

    widget.controller.addListener(onController);
  }

  @override
  void dispose() {
    super.dispose();

    streaming?.cancel();
    print("Stream closed");
    widget.controller.removeListener(onController);
  }

  void onController() {
    if (widget.controller.isStreaming) {
      print("stream resume");
      loadStream();
    } else {
      print("stream paused");
      streaming?.cancel();
      client?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditLabel = Text(
      "公路局即時影像",
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: Colors.white.withOpacity(.35)),
    );
    var streamingImageFrame = AspectRatio(
      aspectRatio: 1.7,
      child: Stack(
        children: [
          // show image from buffer if avaliable
          Positioned.fill(
            child: buffer.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Image.memory(
                    Uint8List.fromList(buffer),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
          ),

          // image credit source tag
          Positioned(
            bottom: 24,
            right: 24,
            child: creditLabel,
          )
        ],
      ),
    );

    return streamingImageFrame;
  }
}
