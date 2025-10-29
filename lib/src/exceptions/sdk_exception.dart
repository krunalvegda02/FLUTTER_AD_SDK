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
  const NetworkException(super.message) : super(code: 'NETWORK_ERROR');
}

class ValidationException extends SDKException {
  const ValidationException(super.message) : super(code: 'VALIDATION_ERROR');
}

class CacheException extends SDKException {
  const CacheException(super.message) : super(code: 'CACHE_ERROR');
}
