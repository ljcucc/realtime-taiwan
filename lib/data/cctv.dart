import 'package:flutter/material.dart' as flutter;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'package:http/http.dart' as http;
import 'package:realtime_taiwan/data/database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:latlong2/latlong.dart';

class CCTVListParser {
  List<Map<String, String>> list = [];

  CCTVListParser(xmlString) {
    final List<dom.Element> cctvsHTML = html_parser
        .parse(xmlString) // (root)
        .children[0] // html
        .children[1] // body
        .children[0] // CCTVList
        .children[3] // CCTVs
        .children; // [cctv]
    final cctvs = List.generate(cctvsHTML.length, (index) {
      final original = cctvsHTML[index];
      final result = Map<String, String>();
      for (var i in original.children) {
        result[i.localName!] = i.innerHtml;
      }
      return result;
    });

    list = cctvs;
  }
}

class CCTVInfo {
  String videoStreamUrl;
  String videoImageUrl;
  int locationType;
  String surveillanceDescription;
  String roadId;
  String roadName;
  int roadClass;
  String roadDirection;
  String locationMile;

  CCTVInfo({
    required this.locationType,
    required this.videoStreamUrl,
    required this.videoImageUrl,
    required this.roadId,
    required this.roadName,
    required this.surveillanceDescription,
    required this.roadClass,
    required this.roadDirection,
    required this.locationMile,
  });
}

class CCTVItem {
  int id;
  LatLng? _loc;
  CCTVInfo? _info;
  Database db;

  CCTVItem({required this.id, required this.db});

  _fetchLoc() {
    print("fetching");
    final row = db.select(
      "SELECT positionlon, positionlat FROM cctvs WHERE id=?;",
      [id],
    )[0];
    _loc = LatLng(row['positionlat'] as double, row['positionlon'] as double);
  }

  _fetchInfo() {
    final row = db.select(
      """SELECT 
      locationtype,
      videostreamurl,
      videoimageurl,
      roadid,
      roadname,
      surveillancedescription,
      roadclass,
      roaddirection,
      locationmile
     FROM cctvs WHERE id=?""",
      [id],
    )[0];
    print("stream: ${row['videostreamurl']}, image: ${row['videoimageurl']}");
    _info = CCTVInfo(
      locationMile: row['locationmile'],
      roadClass: row['roadclass'],
      roadDirection: row['roaddirection'],
      roadId: row['roadid'],
      roadName: row['roadname'],
      surveillanceDescription: row['surveillancedescription'],
      videoImageUrl: row['videoimageurl'],
      videoStreamUrl: row['videostreamurl'],
      locationType: row['locationtype'],
    );
  }

  LatLng get loc {
    if (_loc == null) _fetchLoc();
    return _loc!;
  }

  CCTVInfo get info {
    if (_info == null) _fetchInfo();
    return _info!;
  }
}

class CCTVList {
  // TODO: fix this madness
  final appendSchema = """INSERT INTO cctvs ( 
      cctvid,
      linkid,
      videostreamurl,
      videoimageurl, 
      locationtype, 
      positionlon, 
      positionlat, 
      surveillancedescription, 
      roadid, 
      roadname, 
      roadclass, 
      roaddirection, 
      locationmile
    )  VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?);""";
  final dbSchema = """CREATE TABLE IF NOT EXISTS cctvs (
      id INTEGER PRIMARY KEY,
      cctvid TEXT NOT NULL,
      linkid TEXT NOT NULL,
      videostreamurl TEXT NOT NULL,
      videoimageurl TEXT NOT NULL,
      locationtype INTEGER NOT NULL,
      positionlon REAL NOT NULL,
      positionlat REAL NOT NULL,
      surveillancedescription TEXT NOT NULL,
      roadid TEXT NOT NULL,
      roadname TEXT NOT NULL,
      roadclass INTEGER NOT NULL,
      roaddirection TEXT NOT NULL,
      locationmile TEXT NOT NULL
    );""";

  Database db;

  CCTVList({required this.db}) {
    _initDB();
  }

  loadXML(String xmlString) {
    final parser = CCTVListParser(xmlString);
    final insertRow = db.prepare(appendSchema);
    for (var element in parser.list) {
      insertRow.execute([
        element['cctvid'],
        element['linkid'],
        element['videostreamurl'],
        element['videoimageurl'],
        int.parse(element['locationtype']!),
        double.parse(element['positionlon']!),
        double.parse(element['positionlat']!),
        element['surveillancedescription'],
        element['roadid'],
        element['roadname'],
        int.parse(element['roadclass']!),
        element['roaddirection'],
        element['locationmile'],
      ]);
    }
    insertRow.dispose();
  }

  _initDB() {
    db = sqlite3.openInMemory();
    // _db = sqlite3.open("cctv.db");
    db.execute(dbSchema);
  }

  List<CCTVItem> get all {
    return _ids.map((id) => CCTVItem(id: id, db: db)).toList();
  }

  int get length {
    return db.select("SELECT COUNT(*) FROM cctvs")[0]['COUNT(*)'];
  }

  bool get isEmpty {
    return length == 0;
  }

  List<int> get _ids {
    return db.select("SELECT (id) FROM cctvs").map((Row row) {
      return row['id'] as int;
    }).toList();
  }
}

Future<String> getOpendataCCTV(context) async {
  final xmlString = await flutter.DefaultAssetBundle.of(context)
      .loadString("assets/opendataCCTVs.xml");
  return xmlString;
}

// Future<String> fetchImgBase64(String imageUrl) async {
//   http.Response response = await http
//       .get(Uri.parse(imageUrl), headers: {'Cache-Control': 'no-store'});
//   final bytes = response.bodyBytes;
//   return base64Encode(bytes);
// }
