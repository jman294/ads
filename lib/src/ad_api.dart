library ads.api;

import 'dart:io';

import 'package:ads/src/id.dart';
import 'package:ads/src/ad_server.dart';

class AdApi {
  Future image(AdServer ser, HttpRequest req, Id id) async {
    try {
      List<int> imageData = await new File('ad-images/$id.png').readAsBytes();
      var db = ser.getDb;
      var results = await db.query('SELECT imgurl FROM adinfo WHERE ad_id=$id');
      req.response.headers.add(HttpHeaders.CONTENT_TYPE, 'image/png');
      req.response.add(imageData);
    } catch (FileSystemException) {
      req.response.statusCode = HttpStatus.NOT_FOUND;
      return;
    }
  }

  Future text(AdServer ser, HttpRequest req, Id id) async {
    var db = ser.getDb;
    var tag = await db.query('SELECT tag FROM adinfo WHERE ad_id=$id');
    await tag.forEach((row) {
      req.response.write(row.tag);
    });

  }

  Future click(AdServer ser, HttpRequest req, Id id) async {
    var db = ser.getDb;
    var updateClick = await db.query(
        'UPDATE adclicks SET totalclicks=IFNULL(totalclicks, 0) + 1 WHERE ad_id=$id');
    var url = await db.query('SELECT url FROM adinfo WHERE ad_id=$id');
    await url.forEach((row) {
      req.response.redirect(row.url);
    });
  }
}
