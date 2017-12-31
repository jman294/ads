library ads.messages;

// This class is used to send data back and forth between the
// client and server. It is automatically serialized and
// deserialized by the RPC package.
class Ad {
  String tag;
  int id;
  String b64imagedata;

  // A message class must have a default constructor taking no
  // arguments.
  Ad();

  // Named constructor
  Ad.fromArgs(this.tag, this.id, this.b64imagedata);
}

