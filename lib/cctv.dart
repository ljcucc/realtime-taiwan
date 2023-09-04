import 'dart:convert';

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

Future<String> fetchImgBase64(String imageUrl) async {
  http.Response response = await http
      .get(Uri.parse(imageUrl), headers: {'Cache-Control': 'no-store'});
  final bytes = response.bodyBytes;
  return base64Encode(bytes);
}
