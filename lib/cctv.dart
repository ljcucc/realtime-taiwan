import 'package:flutter/material.dart' as f;
import 'package:html/parser.dart';
import 'package:html/dom.dart';

import 'package:http/http.dart' as http;

class CCTVList {
  List<Map<String, String>> list = [];

  CCTVList(xmlString) {
    final List<Element> cctvsHTML = parse(xmlString) // (root)
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

class StreamImage {
  final String url;
  http.MultipartRequest? _request;
  http.ByteStream? respone;

  StreamImage({required this.url}) {
    // byteStream = http.ByteStream(_requestStream());
    _request = http.MultipartRequest("GET", Uri.parse(url));
  }

  send() async {
    print("sending...");
    final r = await _request!.send();
    respone = r.stream;
    print("done!");
  }
}
