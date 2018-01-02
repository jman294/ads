library ads;

import 'dart:io';
import 'dart:async';
import 'package:ads/src/ad_server.dart';

Future main() async {
  AdServer adServer = new AdServer();
  await adServer.prepare();
  var server = await HttpServer.bind('127.0.0.1', 80);
  server.listen(await adServer.handle);
}
