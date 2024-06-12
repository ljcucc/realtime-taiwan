import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/pages/fullscreen_stream/fullscreen_stream.dart';
import 'package:realtime_taiwan/widgets/bookmark_button.dart';
import 'package:realtime_taiwan/widgets/multipart_streaming.dart';

class CCTVStreamingPage extends StatefulWidget {
  final CCTVItem item;
  final ScrollController controller;
  const CCTVStreamingPage({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  State<CCTVStreamingPage> createState() => _StreamingPageBottomSheetState();
}

class _StreamingPageBottomSheetState extends State<CCTVStreamingPage> {
  final msc = MultipartStreamingController();

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isPhone = [
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.fuchsia
    ].contains(platform);

    final desktopCloseButton = Padding(
      padding: const EdgeInsets.only(left: 16),
      child: IconButton.filledTonal(
        icon: const Icon(Icons.close),
        tooltip: lang(context).streaming_back,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );

    final title = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item.info.roadName!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          "${widget.item.info.locationMile}・${widget.item.info.surveillanceDescription}",
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 2,
          softWrap: false,
          textAlign: TextAlign.left,
          overflow: TextOverflow.fade,
        )
      ],
    );

    final toolbar = Row(
      children: [
        Expanded(child: title),
        const Gap(24),
        BookmarkButton(bookmark: widget.item.bookmark),
        (!isPhone ? desktopCloseButton : Container()),
      ],
    );

    final streamingPreview = GestureDetector(
      onTap: () async {
        msc.pause();
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return FullscreenStreamPage(info: widget.item.info);
          },
          fullscreenDialog: true,
        ));
        msc.resume();
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
        ),
        child: MultipartStream(
          controller: msc,
          info: widget.item.info,
        ),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      controller: widget.controller,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          toolbar,
          const Gap(22),
          streamingPreview,
        ],
      ),
    );
  }
}
