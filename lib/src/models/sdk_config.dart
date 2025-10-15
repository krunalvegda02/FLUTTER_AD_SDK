// lib/src/models/sdk_config.dart
class SDKConfig {
  final String publisherId;
  final String apiKey;
  final String environment;
  final String version;
  final bool enableLogging;
  final Duration timeout;
  final Map<String, dynamic> additionalConfig;

  const SDKConfig({
    required this.publisherId,
    required this.apiKey,
    required this.environment,
    required this.version,
    required this.enableLogging,
    required this.timeout,
    required this.additionalConfig,
  });

  String get baseUrl {
    switch (environment) {
      case 'development':
        return 'https://dev-api.yourplatform.com';
      case 'staging':
        return 'https://staging-api.yourplatform.com';
      case 'mock':
        return 'https://mock-api.example.com';
      case 'production':
      default:
        return 'https://api.yourplatform.com';
    }
  }

  bool get isMockMode => environment == 'mock';

  Map<String, dynamic> toJson() => {
    'publisherId': publisherId,
    'environment': environment,
    'version': version,
    'enableLogging': enableLogging,
    'timeout': timeout.inMilliseconds,
    ...additionalConfig,
  };
}
