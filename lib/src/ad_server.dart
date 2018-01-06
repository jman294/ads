library ads.server;

import 'dart:io';
import 'dart:async';

import 'package:sqljocky/sqljocky.dart';
import 'package:logging/logging.dart';
import 'package:ads/src/ad_api.dart';
import 'package:ads/src/id.dart';
import 'package:ads/src/response.dart';

class AdServer {
  final Logger _log = new Logger('AdServer');
  final ConnectionPool _db = new ConnectionPool(
      host: 'localhost',
      port: 3306,
      user: 'mysql',
      password: 'password',
      db: 'ads',
      max: 5);
  AdApi _adApi;

  // ConnectionPool get db => _db;

  AdServer() {
    Logger.root..level = Level.INFO
               ..onRecord.listen(print);
    _adApi = new AdApi(_db);

  }

  Future handle(HttpRequest req) async {
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    req.response.headers.add('Access-Control-Allow-Methods', 'GET');
    req.response.headers.add('Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept');

    List<String> uriParts = req.uri.pathSegments;

    Response adResp = new Response();
    if (_isValidUri(uriParts)) {
      Id id = new Id(int.parse(uriParts[1]));
      if (uriParts[0] == 'image') {
        adResp = await _adApi.image(this, id);
      } else if (uriParts[0] == 'text') {
        adResp = await _adApi.text(this, id);
      } else if (uriParts[0] == 'click') {
        adResp = await _adApi.click(this, id);
      }
    } else {
      adResp.statusCode = HttpStatus.NOT_FOUND;
      _log.warning('invalid uri');
    }
    if (adResp.e != null) {
      _log.warning(adResp.e.cause, adResp.e);
    }
    _sendApiResponse(adResp, req.response);

    // req.response.?close();
  }

  bool _isValidUri(List<String> uriParts) {
    List<String> apiMethods = ['image', 'text', 'click'];
    if (uriParts.length != 2) {
      return false;
    } else {
      try {
        int.parse(uriParts[1]);
      } on FormatException {
        return false;
      }
      if (!apiMethods.contains(uriParts[0])) {
        return false;
      }
    }
    return true;
  }

  Future _sendApiResponse(Response apiResponse, HttpResponse response) {
    response.statusCode = apiResponse.statusCode;
    response.reasonPhrase = apiResponse.reasonPhrase;
    apiResponse.headers
      .forEach((name, value) => response.headers.add(name, value));
    if (apiResponse.data != null) {
      response.add(apiResponse.data);
    }
    return response.close();
  }
}