import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/tabs/maps/streaming.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late List<BookmarkItem> bookmarks;

  @override
  void initState() {
    super.initState();
    bookmarks = bookmarkList.all;
  }

  Widget ListItem(BookmarkItem bookmark) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        onTap: () {
          openStream(item: bookmark.cctv, context: context);
        },
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Dismissible(
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
            setState(() {
              bookmark.remove();
              bookmarks = bookmarkList.all;
            });
          },
          child: ListTile(
            title: Text(bookmark.cctv.info.roadName),
            subtitle: Text(bookmark.cctv.info.surveillanceDescription),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedList = Expanded(
      child: ListView(
        children: [
          ...bookmarks.map((bookmark) => ListItem(bookmark)),
        ],
      ),
    );
    final noSavedList = Expanded(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Text(
            "奧喔！這裡沒有任何儲存的地點呢，到地圖中蒐藏地點吧。",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "儲存",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 32,
            ),
            bookmarks.isEmpty ? noSavedList : savedList,
          ],
        ),
      ),
    );
  }
}
