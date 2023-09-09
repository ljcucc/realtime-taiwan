import 'dart:io';

import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

late Database database;
late CCTVList cctvList;
// late BookmarkList bookmarkList;

initDatabase() async {
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  database = sqlite3.open(path.join(appDocumentsDir.path, "cctvs.sqlite3"));
  cctvList = CCTVList(db: database);
  // bookmarkList = BookmarkList(db: database);
}

// final database = sqlite3.openInMemory();
