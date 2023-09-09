import 'package:realtime_taiwan/data/cctv.dart';
import 'package:sqlite3/sqlite3.dart';

class BookmarkItem {
  Database db;
  int? id;
  int? cctvId;

  BookmarkItem({
    required this.db,
    this.id,
    this.cctvId,
  });

  _fetchId() {
    if (cctvId == null) return;
    final result = db.select("SELECT * FROM bookmarks WHERE cctv=?", [cctvId]);
    if (result.length == 0) return;
    id = result[0]['id'];
    return id;
  }

  _fetchCCTVId() {
    if (id == null) return;
    final result = db.select("SELECT * FROM bookmarks WHERE id=?", [id]);
    if (result.length == 0) return;
    cctvId = result[0]['cctv'] as int;
  }

  bool get isSaved {
    return _fetchId() != null;
  }

  CCTVItem get cctv {
    return CCTVItem(db: db, id: cctvId ?? 0);
  }

  void add() {
    if (cctvId == null) return;
    db.execute("INSERT INTO bookmarks (cctv) VALUES (?)", [cctvId]);
  }

  void remove() {
    if (id != null)
      db.execute("DELETE FROM bookmarks WHERE id=?", [id]);
    else
      db.execute("DELETE FROM bookmarks WHERE cctv=?", [cctvId]);
  }
}

class BookmarkList {
  Database db;

  final dbSchema = """CREATE TABLE IF NOT EXISTS bookmarks (
    id INTEGER PRIMARY KEY,
    cctv INTEGER,
    FOREIGN KEY (cctv) REFERENCES cctvs (id)
  )""";

  BookmarkList({required this.db}) {
    _initDB();
  }

  _initDB() {
    db.execute(dbSchema);
  }

  int get length {
    return db.select("SELECT * FROM bookmarks").length;
  }

  List<BookmarkItem> get all {
    return db
        .select("SELECT * from bookmarks")
        .map(
          (row) => BookmarkItem(
            db: db,
            id: row['id'],
            cctvId: row['cctv'],
          ),
        )
        .toList();
  }
}
