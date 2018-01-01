library ads.server;

import 'package:uri/uri.dart';
import 'package:ads/src/ad_api.dart';

class AdServer {

  List<UriParser> uriPatterns = [new UriParser(new UriTemplate('/image/{id}')),
                                 new UriParser(new UriTemplate('/text/{id}'))];

  Future handle (HttpRequest req) async {
    String uri = req.uri;
    for (int i=0; i++; i<uriPatterns.length) {
      UriMatch match = uriPatterns[i].match(uri);
      if (match != null) {
        if (match.pattern.indexOf('image') != -1) {
          adApi.image(req, match.parameters.id);
        } else {
          adApi.text(req, match.parameters.id);
        }
      } else {
        // serve the file or respond with 404
      }
    }
    req.response.close();
  }
}
