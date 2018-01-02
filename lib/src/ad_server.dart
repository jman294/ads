library ads.server;

import 'dart:io';
import 'dart:convert';

import 'package:uri/uri.dart';
import 'package:sqljocky/sqljocky.dart';
import 'package:ads/src/ad_api.dart';
import 'package:ads/src/id.dart';
import 'package:ads/src/id_list.dart';

class AdServer {
  AdApi adApi = new AdApi();
  IdList idList = new IdList('ads.list');
  ConnectionPool db = new ConnectionPool(
      host: 'localhost',
      port: 3306,
      user: 'mysql',
      password: 'password',
      db: 'ads',
      max: 5);

  ConnectionPool get getDb => db;

  Future prepare() async {
    await idList.populate();
  }

  Future handle(HttpRequest req) async {
    List<String> uriParts = req.uri.pathSegments;

    if (uriParts.length < 2) {
      req.response.statusCode = HttpStatus.NOT_FOUND;
    } else if (uriParts[0] == 'image') {
      await adApi.image(this, req, new Id(uriParts[1]));
    } else if (uriParts[0] != null && uriParts[0] == 'text') {
      adApi.text(this, req, new Id(uriParts[1]));
    } else if (uriParts[0] != null && uriParts[0] == 'click') {
      adApi.click(this, req, new Id(uriParts[1]));
    } else {
      req.response.statusCode = HttpStatus.NOT_FOUND;
    }

    // Make sure response is closed, even if it already has been
    req.response.close();
  }
}
