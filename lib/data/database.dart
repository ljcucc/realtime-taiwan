import 'dart:io';

import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/cctv.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// late Database database;
late CCTVList cctvList;
late BookmarkList bookmarkList;
String appPath = "";

initDatabase() async {
  Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  appPath = appDocumentsDir.path;

  final database = await openDatabase(appPath);
  cctvList = CCTVList(db: database);
  bookmarkList = BookmarkList(db: database);
}

Future<Database> openDatabase(String p) async {
  print("opening db file from: ${p}");
  return sqlite3.open(path.join(p, "cctvs.sqlite3"));
}

Future<CCTVList> getCctvList(String dbPath) async {
  final database = await openDatabase(dbPath);
  return CCTVList(db: database);
}

// final database = sqlite3.openInMemory();
