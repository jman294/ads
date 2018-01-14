library ads;

import 'dart:io';
import 'dart:async';
import 'package:ads/src/ad_server.dart';

Future main(List<String> args) async {
  AdServer adServer = new AdServer();
  var server = await HttpServer.bind(args[0], 80);
  server.listen(await adServer.handle);
}
