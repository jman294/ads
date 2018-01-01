library ads;

import 'dart:io';
import 'dart:async';
import 'package:ads/src/ad_server.dart';

Future main() async {
  AdServer adServer = new AdServer();
  var server = await HttpServer.bind(InternetAddress.ANY_IP_V6, 80);
  server.listen(adServer.handle);
}
