/// Represents network-related failures such as no connection, timeout, or bad status codes.
class NetworkException implements Exception {
  /// Error message describing the failure.
  final String message;

  /// Optional error code (e.g., "TIMEOUT", "NO_INTERNET").
  final String? code;

  /// Optional additional details for debugging.
  final dynamic details;

  NetworkException(this.message, {this.code, this.details});

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException: $message');
    if (code != null) buffer.write(' (code: $code)');
    if (details != null) buffer.write(' | Details: $details');
    return buffer.toString();
  }
}
