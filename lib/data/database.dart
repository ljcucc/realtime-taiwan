import 'package:realtime_taiwan/data/cctv.dart';
import 'package:sqlite3/sqlite3.dart';

final database = sqlite3.openInMemory();
final cctvList = CCTVList(db: database);
