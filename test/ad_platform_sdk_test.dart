import 'package:flutter_test/flutter_test.dart';
import 'package:ad_platform_sdk/ad_platform_sdk.dart';
import 'package:ad_platform_sdk/ad_platform_sdk_platform_interface.dart';
import 'package:ad_platform_sdk/ad_platform_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdPlatformSdkPlatform
    with MockPlatformInterfaceMixin
    implements AdPlatformSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdPlatformSdkPlatform initialPlatform = AdPlatformSdkPlatform.instance;

  test('$MethodChannelAdPlatformSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdPlatformSdk>());
  });

  test('getPlatformVersion', () async {
    AdPlatformSdk adPlatformSdkPlugin = AdPlatformSdk();
    MockAdPlatformSdkPlatform fakePlatform = MockAdPlatformSdkPlatform();
    AdPlatformSdkPlatform.instance = fakePlatform;

    expect(await adPlatformSdkPlugin.getPlatformVersion(), '42');
  });
}
