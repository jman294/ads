library ads.server;

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:uri/uri.dart';
import 'package:sqljocky/sqljocky.dart';
import 'package:ads/src/ad_api.dart';
import 'package:ads/src/id.dart';
import 'package:ads/src/id_list.dart';

class AdServer {
  AdApi adApi = new AdApi();
  ConnectionPool db = new ConnectionPool(
      host: 'localhost',
      port: 3306,
      user: 'mysql',
      password: 'password',
      db: 'ads',
      max: 5);

  ConnectionPool get getDb => db;

  Future handle(HttpRequest req) async {
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    req.response.headers.add('Access-Control-Allow-Methods', 'GET');
    req.response.headers.add('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept');

    List<String> uriParts = req.uri.pathSegments;

    if (uriParts.length < 2) {
      req.response.statusCode = HttpStatus.NOT_FOUND;
    } else if (uriParts[0] == 'image') {
      await adApi.image(this, req, new Id(uriParts[1]));
    } else if (uriParts[0] == 'text') {
      await adApi.text(this, req, new Id(uriParts[1]));
    } else if (uriParts[0] == 'click') {
      await adApi.click(this, req, new Id(uriParts[1]));
    } else {
      req.response.statusCode = HttpStatus.NOT_FOUND;
    }

    // Make sure response is closed, even if it already has been
    await req.response.close();
  }
}
