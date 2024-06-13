import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/pages/cctv_streaming_page.dart';

class StreamingBottomSheet extends StatelessWidget {
  final CCTVItem item;

  const StreamingBottomSheet({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.9,
      minChildSize: 0.35,
      initialChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return CCTVStreamingPage(
          controller: scrollController,
          item: item,
        );
      },
    );
  }
}
