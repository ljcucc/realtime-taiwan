import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:realtime_taiwan/data/lang.dart';
import 'package:realtime_taiwan/tabs/maps/streaming.dart';
import 'package:realtime_taiwan/tabs/saved/saved_gridview.dart';
import 'package:realtime_taiwan/tabs/saved/saved_listview.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final emptyHint = Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            const Gap(24),
            Text(
              lang(context).saved_none,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    final title = Text(
      lang(context).tab_saved,
      style: Theme.of(context).textTheme.titleLarge,
    );

    final deviceWidth = MediaQuery.of(context).size.width;
    final list =
        deviceWidth > 600 ? const SavedGridView() : const SavedListView();

    final listview = SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            title,
            const Gap(32),
            list,
          ],
        ),
      ),
    );

    final emptyview = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        title,
        Expanded(
          child: Center(
            child: emptyHint,
          ),
        ),
      ]),
    );

    return Consumer<BookmarkListModel>(builder: (context, blm, child) {
      return SafeArea(
        child: blm.listBookmarks().isEmpty ? emptyview : listview,
      );
    });
  }
}
