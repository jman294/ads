library ads.error;

class AdException implements Exception {
  String cause;
  AdException(this.cause);
}
