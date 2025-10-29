import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ad_integration_sdk_platform_interface.dart';

/// An implementation of [AdIntegrationSdkPlatform] that uses method channels.
class MethodChannelAdIntegrationSdk extends AdIntegrationSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ad_integration_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
