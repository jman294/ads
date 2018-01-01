library ads.id_list;

import 'package:ads/src/id.dart';

class IdList {
  List<Id> ids = [];
  File file;

  IdList (fileName) {
    this.file = new File(fileName);
    await populate();
  }

  Future populate () async {
    print('Making a list');
  }
}
