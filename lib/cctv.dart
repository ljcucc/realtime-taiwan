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

class ImageStreaming {
  final String url;
  final Function onImage;

  http.MultipartRequest? _request;
  http.ByteStream? respone;

  List<int> buffer = [];

  ImageStreaming({required this.url, required this.onImage}) {
    // byteStream = http.ByteStream(_requestStream());
    _request = http.MultipartRequest("GET", Uri.parse(url));
  }

  send() async {
    final r = await _request!.send();
    final contentType = r.headers['content-type']!.split("=")[1];
    print(contentType);

    await for (final value in r.stream) {
      buffer.addAll(value);

      var newIndex =
          (String.fromCharCodes(buffer).indexOf("--${contentType}", 1));
      if (newIndex == -1) continue;

      sendImage(buffer.getRange(0, newIndex).toList());
      buffer = buffer.getRange(newIndex, buffer.length).toList();
    }
  }

  sendImage(List<int> buffer) {
    // find the "Content-length: ???" line and count from it after
    final lenStr = String.fromCharCodes(buffer).split("\n")[2];
    print(lenStr);
    // len before Content-length + Content-length itself + newline
    final index =
        String.fromCharCodes(buffer).indexOf(lenStr) + lenStr.length + 1;
    final len = int.parse(lenStr.split(":")[1].trim());
    final result = buffer.getRange(index, len).toList();
    print(base64.encode(result));
    onImage(result);
  }
}
