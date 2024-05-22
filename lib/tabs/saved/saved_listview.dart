import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/tabs/maps/streaming.dart';

class SavedListViewItem extends StatelessWidget {
  final BookmarkItem bookmark;
  const SavedListViewItem({
    super.key,
    required this.bookmark,
  });

  @override
  Widget build(BuildContext context) {
    final image = Container(
      clipBehavior: Clip.antiAlias,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: AspectRatio(
        child: Image.network(
          fit: BoxFit.cover,
          bookmark.cctv.info.videoImageUrl,
        ),
        aspectRatio: 1,
      ),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          openStream(item: bookmark.cctv, context: context);
        },
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Dismissible(
          resizeDuration: const Duration(milliseconds: 500),
          movementDuration: const Duration(milliseconds: 500),
          direction: DismissDirection.endToStart,
          background: Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.error,
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.delete_outline,
              size: 28,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          key: ValueKey(bookmark.id),
          onDismissed: (e) {
            final blm = Provider.of<BookmarkListModel>(context, listen: false);
            blm.removeBookmark(bookmark);
          },
          child: Row(
            children: [
              image,
              Expanded(
                child: ListTile(
                  title: Text(bookmark.cctv.info.roadName),
                  subtitle: Text(bookmark.cctv.info.surveillanceDescription),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SavedListView extends StatelessWidget {
  const SavedListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarkListModel>(builder: (context, blm, _) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...blm.listBookmarks().map(
                (bookmark) => SavedListViewItem(bookmark: bookmark),
              ),
        ],
      );
    });
  }
}
