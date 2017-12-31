library ads.server;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:rpc/rpc.dart';
import '../common/messages.dart';

// This class defines the interface that the server provides.
@ApiClass(name: 'ad', version: 'v1')
class AdApi {
  final Base64Encoder b64e = new Base64Encoder();

  @ApiMethod(method: 'GET', path: 'id/{id}')
  Future<Ad> getAdById (int id) async {
    var imageBytes = await new File('ad-images/$id.png').readAsBytes();
    Ad newAd = new Ad.fromArgs("Farts", id, b64e.convert(imageBytes));
    return newAd;
  }
}
