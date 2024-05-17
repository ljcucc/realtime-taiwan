import 'dart:convert';

import 'package:flutter/material.dart' as flutter;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'package:http/http.dart' as http;
import 'package:realtime_taiwan/data/bookmark.dart';
import 'package:realtime_taiwan/data/database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter/services.dart' show rootBundle;

/// XML to dictionary data parser for openData XML
class CCTVListParser {
  List<Map<String, String>> list = [];

  CCTVListParser(
    xmlString, {
    Function? onParse,
  }) {
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

  /// auto fetch position geo data if not cached
  _fetchLoc() {
    final row = db.select(
      "SELECT positionlon, positionlat FROM cctvs WHERE id=?;",
      [id],
    )[0];
    _loc = LatLng(row['positionlat'] as double, row['positionlon'] as double);
  }

  /// auto fetch rest of the infomation from database
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

  BookmarkItem get bookmark {
    return BookmarkItem(db: db, cctvId: id);
  }
}

/// a manager that will create database, dump all parsed xml data to database, get List<CCTVItem> from it.
class CCTVList {
  // TODO: fix this madness

  /// insert schema used to insert a complete row into sqlite database
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

  /// Database schema
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

  /// load XMLString, parse it and dump into database
  Future<void> loadXML(String xmlString) async {
    print("parsing");
    final parser = CCTVListParser(xmlString);
    print("inserting...");
    final insertRow = db.prepare(appendSchema);
    int items = 0;
    for (var element in parser.list) {
      print("${++items}");
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
      // await Future.delayed(Duration(milliseconds: 10));
    }
    insertRow.dispose();
  }

  _initDB() {
    db.execute(dbSchema);
  }

  /// get CCTVItem List with init state
  List<CCTVItem> get all {
    return _ids.map((id) => CCTVItem(id: id, db: db)).toList();
  }

  /// get total length of database
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

/// get data based on https://data.gov.tw/en/datasets/29817
Future<String> getOpendataCCTV() async {
  print("fetching xml from assets folder...");
  final response = rootBundle.loadString("assets/opendataCCTVs.xml");
  return response;
}
