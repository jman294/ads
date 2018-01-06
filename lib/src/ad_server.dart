library ads.server;

import 'dart:io';
import 'dart:async';

import 'package:sqljocky/sqljocky.dart';
import 'package:logging/logging.dart';
import 'package:ads/src/ad_api.dart';
import 'package:ads/src/id.dart';
import 'package:ads/src/ad_error.dart';
import 'package:ads/src/response.dart';

class AdServer {
  final Logger _log = new Logger('AdServer');
  final AdApi _adApi = new AdApi();
  final ConnectionPool _db = new ConnectionPool(
      host: 'localhost',
      port: 3306,
      user: 'mysql',
      password: 'password',
      db: 'ads',
      max: 5);

  ConnectionPool get db => _db;

  AdServer() {
    Logger.root..level = Level.INFO
               ..onRecord.listen(print);
  }

  Future handle(HttpRequest req) async {
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    req.response.headers.add('Access-Control-Allow-Methods', 'GET');
    req.response.headers.add('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept');

    List<String> uriParts = req.uri.pathSegments;

    if (_isValidUri(uriParts)) {
      if (uriParts[0] == 'image') {
        Response adResp = await _adApi.image(this, new Id(int.parse(uriParts[1])));
        _sendApiResponse(adResp, req.response);
        if (adResp.e != null) {
          _log.warning(adResp.e.cause, adResp.e);
        }
      } else if (uriParts[0] == 'text') {
        Response adResp = await _adApi.text(this, new Id(int.parse(uriParts[1])));
        _sendApiResponse(adResp, req.response);
        if (adResp.e != null) {
          _log.warning(adResp.e.cause, adResp.e);
        }
      } else if (uriParts[0] == 'click') {
        Response adResp = await _adApi.click(this, new Id(int.parse(uriParts[1])));
        _sendApiResponse(adResp, req.response);
        if (adResp.e != null) {
          _log.warning(adResp.e.cause, adResp.e);
        }
      } else {
        req.response.statusCode = HttpStatus.NOT_FOUND;
        _log.info('invalid uri');
      }
    } else {
      req.response.statusCode = HttpStatus.NOT_FOUND;
      _log.info('invalid uri');
    }

    // Make sure response is closed, even if it already has been
    await req.response.close();
  }

  bool _isValidUri(List<String> uriParts) {
    if (uriParts.length != 2) {
      return false;
    } else {
      try {
        int.parse(uriParts[1]);
      } on FormatException {
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
    response.close();
  }

}