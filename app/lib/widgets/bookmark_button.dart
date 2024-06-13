import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/lang.dart';

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

    final blist = Provider.of<BookmarkListModel>(context, listen: false);

    if (saved) {
      blist.addBookmark(widget.bookmark);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang(context).streaming_saved_msg)),
      );
    } else {
      blist.removeBookmark(widget.bookmark);
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
      selectedIcon: const Icon(Icons.bookmark),
      icon: const Icon(Icons.bookmark_border),
      tooltip: lang(context).streaming_save,
    );
  }
}
