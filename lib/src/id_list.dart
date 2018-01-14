library ads.id_list;

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:ads/src/id.dart';

class IdList {
  List<Id> ids = [];
  File file;

  IdList (fileName) {
    this.file = new File(fileName);
  }

  Future populate () async {
    Stream<List<int>> inputStream = file.openRead();

    inputStream
      .transform(UTF8.decoder)       // Decode bytes to UTF8.
      .transform(new LineSplitter()) // Convert stream to individual lines.
      .listen((String line) {        // Process results.
        ids.add(new Id.string(line));
      },
      onDone: () { },
      onError: (e) { print(e.toString()); });
  }
}
