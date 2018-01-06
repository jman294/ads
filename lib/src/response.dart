library ads.response;

import 'dart:io';
import 'dart:convert';

import 'package:ads/src/ad_error.dart';

class Response {
  int _statusCode = HttpStatus.OK;
  Map<String, String> _headers = {};
  List<int> _data = [];
  String _reasonPhrase;
  AdException _e;
  final Utf8Encoder encoder = new Utf8Encoder();


  Map<String, String> get headers => _headers;
  int get statusCode => _statusCode;
  List<int> get data => _data;
  String get reasonPhrase => _reasonPhrase;
  AdException get e => _e;

  void set statusCode(int statusCode) {
    _statusCode = statusCode;
  }
  void set reasonPhrase(String reasonPhrase) {
    _reasonPhrase = reasonPhrase;
  }
  void set e(AdException e) {
    _e = e;
  }

  void add(List<int> data) {
    _data = data;
  }
  void write(String str) {
    _data.insertAll(_data.length, encoder.convert(str));
  }

  Response();
  factory Response.error(int statusCode, AdException e) {
    Response res = new Response();
    res.e = e;
    res.statusCode = statusCode;
    res.reasonPhrase = e.cause;
    return res;
  }
}