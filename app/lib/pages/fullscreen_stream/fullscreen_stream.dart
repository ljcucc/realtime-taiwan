import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/widgets/multipart_streaming.dart';

class FullscreenStreamPage extends StatefulWidget {
  final CCTVInfo info;
  const FullscreenStreamPage({
    super.key,
    required this.info,
  });

  @override
  State<FullscreenStreamPage> createState() => _FullscreenViewPageState();
}

class _FullscreenViewPageState extends State<FullscreenStreamPage> {
  final msc = MultipartStreamingController();

  close(context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final video = InteractiveViewer(
      child: Center(
        child: MultipartStream(
          controller: msc,
          info: widget.info,
        ),
      ),
    );

    final appbar = AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Text(widget.info.roadName),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: video),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: appbar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
