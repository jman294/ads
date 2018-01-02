import 'dart:io';
import 'dart:async';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:ads/src/ad_server.dart';
import 'package:ads/src/ad_api.dart';

class MockAdApi extends Mock implements AdApi {}
class MockServer extends Mock implements AdServer {}
class MockResponse extends Mock implements HttpResponse {}
class MockRequest extends Mock implements HttpRequest {
  MockResponse mresponse = new MockResponse();
  HttpResponse get response => mresponse;
}

void main() {
  MockServer server;
  MockRequest request = new MockRequest();

  setUp(() {
    server = new MockServer();
  });

  group('AdServer', () {
    test('.handle() should return', () async {
      await server.handle(server);
    });
  });
}
