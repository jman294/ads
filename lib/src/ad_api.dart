library ads.api;

import 'dart:io';

import 'package:ads/src/id.dart';
import 'package:ads/src/ad_server.dart';

class AdApi {
  void image (AdServer ser, HttpRequest req, Id id) async {
    try {
      List<int> imageData = await new File('ad-images/$id.png').readAsBytes();
      var db = ser.getDb;
      var results = await db.query('select imgurl from adinfo where ad_id = $id');
      print(results);
      req.response.headers.add(HttpHeaders.CONTENT_TYPE, 'image/png');
      req.response.add(imageData);
    } catch (FileSystemException) {
      req.response.statusCode = HttpStatus.NOT_FOUND;
      return;
    }

  }

  void text (AdServer ser, HttpRequest req, Id id) {
  }

  void click (AdServer ser, HttpRequest req, Id id) {
    req.response.redirect('http://google.com');
  }
}
