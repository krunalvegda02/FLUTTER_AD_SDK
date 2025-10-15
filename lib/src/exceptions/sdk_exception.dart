// lib/src/exceptions/sdk_exception.dart
class SDKException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const SDKException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'SDKException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends SDKException {
  const NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class ValidationException extends SDKException {
  const ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}

class CacheException extends SDKException {
  const CacheException(String message) : super(message, code: 'CACHE_ERROR');
}
