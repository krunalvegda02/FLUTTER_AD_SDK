import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ad_integration_sdk_method_channel.dart';

abstract class AdIntegrationSdkPlatform extends PlatformInterface {
  /// Constructs a AdIntegrationSdkPlatform.
  AdIntegrationSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdIntegrationSdkPlatform _instance = MethodChannelAdIntegrationSdk();

  /// The default instance of [AdIntegrationSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdIntegrationSdk].
  static AdIntegrationSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdIntegrationSdkPlatform] when
  /// they register themselves.
  static set instance(AdIntegrationSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
