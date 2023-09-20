import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:realtime_taiwan/data/lang.dart';

void PlatformVideoWidget() {
  if (true) {}
}

class StreamingImage extends StatefulWidget {
  final CCTVInfo info;

  const StreamingImage({
    super.key,
    required this.info,
  });

  @override
  State<StreamingImage> createState() => _StreamingPageState();
}

class _StreamingPageState extends State<StreamingImage> {
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
    var streamingImage = AspectRatio(
      aspectRatio: 1.7,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              "${widget.info.videoImageUrl}?${time}",
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Text(
              "公路局即時影像",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.white.withOpacity(.35)),
            ),
          )
        ],
      ),
    );

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
          child: streamingImage,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

class StreamingPageBottomSheet extends StatelessWidget {
  final CCTVItem item;
  final ScrollController controller;
  const StreamingPageBottomSheet(
      {super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isPhone = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.all(16).copyWith(
        top:
            platform == TargetPlatform.android || platform == TargetPlatform.iOS
                ? 0
                : null,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isPhone ? 0 : 8),
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.info.roadName!,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              "${item.info.locationMile}・${item.info.surveillanceDescription}",
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              softWrap: false,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.fade,
                            )
                          ],
                        ),
                      ),
                      // Spacer(),
                      Padding(
                        padding: EdgeInsets.only(left: 24),
                        child: BookmarkButton(
                          bookmark: item.bookmark,
                        ),
                      ),
                      (!isPhone
                          ? Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: IconButton.filledTonal(
                                icon: Icon(Icons.close),
                                tooltip: lang(context).streaming_back,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            )
                          : Container()),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return FullscreenViewPage(info: item.info);
                      },
                      fullscreenDialog: true,
                    ));
                  },
                  child: StreamingImage(info: item.info),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BookmarkButton extends StatefulWidget {
  final BookmarkItem bookmark;

  const BookmarkButton({super.key, required this.bookmark});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool saved = false;

  @override
  void initState() {
    super.initState();

    saved = widget.bookmark.isSaved;
  }

  void toggle() {
    setState(() {
      saved = !saved;
    });

    if (saved) {
      widget.bookmark.add();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang(context).streaming_saved_msg)),
      );
    } else {
      widget.bookmark.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      iconSize: 24,
      onPressed: () {
        toggle();
      },
      isSelected: saved,
      selectedIcon: Icon(Icons.bookmark),
      icon: Icon(Icons.bookmark_border),
      tooltip: lang(context).streaming_save,
    );
  }
}

class FullscreenViewPage extends StatelessWidget {
  final CCTVInfo info;
  const FullscreenViewPage({
    super.key,
    required this.info,
  });

  close(context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(info.roadName!),
        // leading: IconButton(
        //   icon: Icon(Icons.close),
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        // ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          child: InteractiveViewer(
            child: Center(
              child: StreamingImage(
                info: info,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      return DraggableScrollableSheet(
        maxChildSize: 0.9,
        minChildSize: 0.35,
        initialChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            child: StreamingPageBottomSheet(
              controller: scrollController,
              item: item,
            ),
          );
        },
      );
    },
  );
}
