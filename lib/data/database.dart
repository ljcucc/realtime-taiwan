import 'dart:io';

import 'package:realtime_taiwan/data/cctv.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

late Database database;
late CCTVList cctvList;
initDatabase() async {
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  database = sqlite3.open(path.join(appDocumentsDir.path, "cctvs.sqlite3"));
  cctvList = CCTVList(db: database);
}

// final database = sqlite3.openInMemory();
