import 'package:flutter/material.dart';
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/database.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "儲存",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 32,
            ),
            bookmarks.length == 0
                ? Expanded(
                    child: Container(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          "奧喔！這裡沒有任何儲存的地點呢，到地圖中蒐藏地點吧。",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView(
                      children: [
                        ...bookmarks.map(
                          (bookmark) => Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            child: InkWell(
                              onTap: () {},
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              child: Dismissible(
                                direction: DismissDirection.endToStart,
                                child: ListTile(
                                  title: Text(bookmark.cctv.info.roadName),
                                  subtitle: Text(bookmark
                                      .cctv.info.surveillanceDescription),
                                ),
                                background: Container(
                                  padding: EdgeInsets.all(16),
                                  color: Theme.of(context).colorScheme.error,
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 28,
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                  ),
                                  alignment: Alignment.centerRight,
                                ),
                                key: ValueKey(bookmark.id),
                                onDismissed: (e) {
                                  setState(() {
                                    bookmark.remove();
                                    bookmarks = bookmarkList.all;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
