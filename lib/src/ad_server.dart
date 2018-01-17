library ads.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase/firebase_io.dart';
import 'package:logging/logging.dart';
import 'package:ads/src/ad_api.dart';
import 'package:ads/src/id.dart';
import 'package:ads/src/response.dart';

class AdServer {
  final Logger _log = new Logger('AdServer');
  AdApi _adApi;
  FirebaseClient _fbClient;

  AdServer() {
    Logger.root
      ..level = Level.INFO
      ..onRecord.listen(print);
  }

  Future auth() async {
    final Map<String, String> envVars = Platform.environment;
    String privateKey;

    if (envVars['WEBSITE'] != null) {
      privateKey = (await http.get(envVars['WEBSITE'])).body;
    } else {
      throw new Exception('Could not Authenticate');
    }

    final String json = new JsonDecoder().convert(privateKey);
    final ServiceAccountCredentials accountCredentials =
        new ServiceAccountCredentials.fromJson(json);
    final List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/userinfo.email'
    ];
    final http.Client client = new http.Client();
    final AccessCredentials credentials =
        await obtainAccessCredentialsViaServiceAccount(
            accountCredentials, scopes, client);
    _fbClient = new FirebaseClient(credentials.accessToken.data);
    _adApi = new AdApi(_fbClient, 'https://adserver-fc752.firebaseio.com/');
    client.close();
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
