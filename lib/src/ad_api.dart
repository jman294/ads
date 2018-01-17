library ads.api;

import 'dart:io';
import 'dart:async';

import 'package:firebase/firebase_io.dart';
import 'package:ads/src/id.dart';
import 'package:ads/src/ad_error.dart';
import 'package:ads/src/ad_errors.dart';
import 'package:ads/src/response.dart';

class AdApi {
  FirebaseClient _db;
  String _host;
  AdApi(this._db, this._host);

  Future<Response> image(Id id) async {
    final String results =
        await _db.get('$_host/$id/imgurl.json');
    List<int> imageData;
    if (await results.isEmpty) {
      return new Response.error(
          HttpStatus.NOT_FOUND, new AdException(AdErrors.adNotFound));
    } else {
      try {
        imageData = await new File('ad-images/$id.png').readAsBytes();
      } catch (FileSystemException) {
        return new Response.error(HttpStatus.INTERNAL_SERVER_ERROR,
            new AdException(AdErrors.imageNotRead));
        // FIXME Error here? Will probably change in the future
      }

      Response res = new Response();
      res.headers[HttpHeaders.CONTENT_TYPE] = 'image/png';
      res.add(imageData);
      return res;
    }
  }

  Future<Response> text(Id id) async {
    final String result =
        await _db.get('$_host/$id/tag.json');
    if (result == '') {
      return new Response.error(
          HttpStatus.NOT_FOUND, new AdException(AdErrors.adNotFound));
    } else {
      Response res = new Response();
      res.headers[HttpHeaders.CONTENT_TYPE] = 'text/plain';
      res.write(result);
      return res;
    }
  }

  Future<Response> click(Id id) async {
    final String clicks =
        await _db.get('$_host/$id/clicks.json');
    if (clicks == null) {
      return new Response.error(
          HttpStatus.NOT_FOUND, new AdException(AdErrors.adNotFound));
    }
    await _db.patch('$_host/$id.json',
        {'clicks': clicks + 1});
    final String url =
        await _db.get('$_host/$id/url.json');
    if (url == '') {
      return new Response.error(
          HttpStatus.NOT_FOUND, new AdException(AdErrors.adNotFound));
    } else {
      Response res = new Response();
      res.headers[HttpHeaders.LOCATION] = url;
      res.statusCode = HttpStatus.MOVED_TEMPORARILY;
      return res;
    }
  }
}
