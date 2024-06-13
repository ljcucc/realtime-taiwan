import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/widgets/streaming_bottom_sheet.dart';

openStream({
  required CCTVItem item,
  required BuildContext context,
}) async {
  final platform = Theme.of(context).platform;

  showModalBottomSheet(
    useSafeArea: true,
    isScrollControlled: true,
    isDismissible: true,
    showDragHandle:
        platform == TargetPlatform.android || platform == TargetPlatform.iOS,
    context: context,
    builder: (context) {
      return StreamingBottomSheet(item: item);
    },
  );
}
