import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:sqljocky/sqljocky.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:ads/src/ad_api.dart';
import 'package:ads/src/id.dart';

class MockResults extends Mock implements Stream {
  bool isEmpty = false;
  List<String> list = ['aa'];

  toList() {
    return list;
  }
}

class MockConnectionPool extends Mock implements ConnectionPool {
  MockResults mockResults = new MockResults();

  MockConnectionPool();

  query(String str) {
    return mockResults;
  }
}

void main() {
  AdApi adApi;
  MockConnectionPool cPool;

  final bool GOOD_ID = false;
  final bool BAD_ID = true;

  setUp(() {
    cPool = new MockConnectionPool();
    adApi = new AdApi(cPool);
  });

  group('AdApi', () {
    test('.image() should have correct response for good id', () async {
      expect((await adApi.image(new Id(1))).headers['content-type'], equals('image/png'));
      expect((await adApi.image(new Id(1))).statusCode, inInclusiveRange(200, 299));
    });
    test('.image() should have error response for bad id', () async {
      cPool.mockResults.isEmpty = BAD_ID;
      adApi = new AdApi(cPool);
      expect((await adApi.image(new Id(-1))).statusCode, equals(404));
    });
    test('.image() should contain image on good id', () async {
      cPool.mockResults.isEmpty = GOOD_ID;
      adApi = new AdApi(cPool);
      List<int> image = await new File('ad-images/1.png').readAsBytes();
      expect((await adApi.image(new Id(1))).data, equals(image));
    });

    test('.text() should have correct response for good id', () async {
      expect((await adApi.text(new Id(1))).headers['content-type'], equals('text/plain'));
      expect((await adApi.text(new Id(1))).statusCode, inInclusiveRange(200, 299));
    });
    test('.text() should have error response for bad id', () async {
      cPool.mockResults.list = [];
      adApi = new AdApi(cPool);
      expect((await adApi.text(new Id(-1))).statusCode, equals(404));
    });
    test('.text() should contain tagline on good id', () async {
      expect((await adApi.text(new Id(1))).data, equals(new Utf8Encoder().convert(cPool.mockResults.list[0][0])));
    });

    test('.click() should have correct response for good id', () async {
      // MockResults.list is a list of strings here, but in reality it is a type defined is sqljocky. That's why this test is weird
      // FIXME
      expect((await adApi.click(new Id(1))).headers['location'], equals(cPool.mockResults.list[0][0]));
      expect((await adApi.click(new Id(1))).statusCode, equals(302));
    });
    test('.click() should have error response for bad id', () async {
      cPool.mockResults.list = [];
      adApi = new AdApi(cPool);
      expect((await adApi.click(new Id(-1))).statusCode, equals(404));
    });
    test('.click() should contain no body on good id', () async {
      cPool.mockResults.list = [];
      // adApi = new AdApi(cPool);
      expect((await adApi.click(new Id(1))).data, equals([]));
    });
  });
}