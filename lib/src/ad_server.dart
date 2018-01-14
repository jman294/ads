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

  AdServer() {
    Logger.root..level = Level.INFO
               ..onRecord.listen(print);
    _adApi = new AdApi(_db);
  }

  Future handle(HttpRequest req) async {
    _addCorsHeaders(req);

    List<String> uriParts = req.uri.pathSegments;
    Map<String, Function> apiMap = {
      'image': _adApi.image,
      'text': _adApi.text,
      'click': _adApi.click
    };

    Response adResp = new Response();
    if (_isValidUri(uriParts)) {
      Id id = new Id(int.parse(uriParts[1]));
      adResp = await apiMap[uriParts[0]](id);
    } else {
      adResp.statusCode = HttpStatus.NOT_FOUND;
      _log.warning('invalid uri');
    }
    if (adResp.e != null) {
      _log.warning(adResp.e.cause, adResp.e);
    }
    _sendApiResponse(adResp, req.response);
  }

  _addCorsHeaders(HttpRequest req) {
    req.response.headers.add('Access-Control-Allow-Origin', '*');
    req.response.headers.add('Access-Control-Allow-Methods', 'GET');
    req.response.headers.add('Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept');
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