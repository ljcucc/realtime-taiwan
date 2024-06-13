import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/tabs/maps/streaming.dart';

class GridViewItem extends StatefulWidget {
  final BookmarkItem bookmark;

  const GridViewItem({
    super.key,
    required this.bookmark,
  });

  @override
  State<GridViewItem> createState() => _GridViewItemState();
}

class _GridViewItemState extends State<GridViewItem> {
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final cctvInfo = widget.bookmark.cctv.info;
    final preview = Image.network(
      cctvInfo.videoImageUrl,
      fit: BoxFit.cover,
    );

    return Card(
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          openStream(item: widget.bookmark.cctv, context: context);
        },
        borderRadius: borderRadius,
        child: Container(
          width: 200,
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(borderRadius: borderRadius),
                  width: double.infinity,
                  child: preview,
                ),
              ),
              ListTile(
                title: Text(widget.bookmark.cctv.info.roadName),
                subtitle: Text(
                  cctvInfo.surveillanceDescription,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SavedGridView extends StatelessWidget {
  const SavedGridView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkListModel>(builder: (context, blm, _) {
      final list = blm
          .listBookmarks()
          .map<Widget>(
            (item) => GridViewItem(bookmark: item),
          )
          .toList();
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: list,
      );
    });
  }
}
