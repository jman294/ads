library ads.api;

import 'dart:io';
import 'dart:async';

import 'package:sqljocky/sqljocky.dart';
import 'package:ads/src/id.dart';
import 'package:ads/src/ad_server.dart';
import 'package:ads/src/ad_error.dart';
import 'package:ads/src/ad_errors.dart';
import 'package:ads/src/response.dart';

class AdApi {
  ConnectionPool _db;
  AdApi(this._db);

  Future<Response> image(AdServer ser, Id id) async {
    var results = await _db.query('SELECT imgurl FROM adinfo WHERE ad_id=$id');
    List<int> imageData;
    if (await results.isEmpty) {
      return new Response.error(HttpStatus.NOT_FOUND, new AdException(AdErrors.adNotFound));
    } else {
      try {
        imageData = await new File('ad-images/$id.png').readAsBytes();
      } catch (FileSystemException) {
        return new Response.error(HttpStatus.INTERNAL_SERVER_ERROR, new AdException(AdErrors.imageNotRead));
        // FIXME Error here? Will probably change in the future
      }

      Response res = new Response(); 
      res.headers[HttpHeaders.CONTENT_TYPE] = 'image/png';
      res.add(imageData);
      return res;
    }
  }

  Future<Response> text(AdServer ser, Id id) async {
    var results = await _db.query('SELECT tag FROM adinfo WHERE ad_id=$id');
    var rows = await results.toList();
    if (rows.isEmpty) {
      return new Response.error(HttpStatus.NOT_FOUND, new AdException(AdErrors.adNotFound));
    } else {
      Response res = new Response();
      res.write(rows[0].tag);
      return res;
    }
  }

  Future<Response> click(AdServer ser, Id id) async {
    var updateClick = await _db.query(
        'UPDATE adclicks SET totalclicks=IFNULL(totalclicks, 0) + 1 WHERE ad_id=$id');
    if (updateClick.affectedRows == 0) {
      return new Response.error(HttpStatus.NOT_FOUND, new AdException(AdErrors.adNotFound));
    }
    var url = await _db.query('SELECT url FROM adinfo WHERE ad_id=$id');
    var rows = await url.toList();
    if (rows.isEmpty) {
      return new Response.error(HttpStatus.NOT_FOUND, new AdException(AdErrors.adNotFound));
    } else {
      Response res = new Response();
      res.headers[HttpHeaders.LOCATION]= rows[0].url;
      res.statusCode = HttpStatus.MOVED_TEMPORARILY;
      return res;
    }
  }
}
