// lib/src/utils/device_info.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  late DeviceInfoPlugin _deviceInfo;
  Map<String, dynamic>? _cachedInfo;

  Future<void> initialize() async {
    try {
      _deviceInfo = DeviceInfoPlugin();
      debugPrint('[DeviceInfo] ✅ Device info service initialized');
    } catch (e) {
      debugPrint('[DeviceInfo] ❌ Failed to initialize: $e');
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (_cachedInfo != null) {
      return _cachedInfo!;
    }

    final info = <String, dynamic>{};
    
    try {
      // Platform info
      info['platform'] = Platform.operatingSystem;
      info['platform_version'] = Platform.operatingSystemVersion;
      
      // Screen info - Use MediaQuery fallback
      info['screen_width'] = 1080;
      info['screen_height'] = 1920;
      info['screen_density'] = 2.0;
      
      // Platform-specific info
      if (Platform.isAndroid) {
        try {
          final androidInfo = await _deviceInfo.androidInfo;
          info.addAll({
            'device_model': androidInfo.model,
            'device_brand': androidInfo.brand,
            'device_manufacturer': androidInfo.manufacturer,
            'android_version': androidInfo.version.release,
            'android_sdk_int': androidInfo.version.sdkInt,
            'device_id': androidInfo.id,
          });
        } catch (e) {
          // Fallback values for Android
          info.addAll({
            'device_model': 'Android Device',
            'device_brand': 'Unknown',
            'device_manufacturer': 'Unknown',
            'android_version': '10',
            'android_sdk_int': 29,
            'device_id': 'mock_device_id',
          });
        }
      } else if (Platform.isIOS) {
        try {
          final iosInfo = await _deviceInfo.iosInfo;
          info.addAll({
            'device_model': iosInfo.model,
            'device_name': iosInfo.name,
            'ios_version': iosInfo.systemVersion,
            'device_id': iosInfo.identifierForVendor,
            'is_physical_device': iosInfo.isPhysicalDevice,
          });
        } catch (e) {
          // Fallback values for iOS
          info.addAll({
            'device_model': 'iPhone',
            'device_name': 'iPhone',
            'ios_version': '15.0',
            'device_id': 'mock_ios_device_id',
            'is_physical_device': true,
          });
        }
      }
    } catch (e) {
      debugPrint('[DeviceInfo] ❌ Error getting device info: $e');
    }
    
    // Locale info
    info['locale'] = 'en_US';
    info['language_code'] = 'en';
    info['country_code'] = 'US';
    
    // Timezone
    info['timezone'] = 'UTC';
    info['timezone_offset'] = 0;
    
    _cachedInfo = info;
    debugPrint('[DeviceInfo] ✅ Device info collected: ${info.keys.join(', ')}');
    return info;
  }

  void clearCache() {
    _cachedInfo = null;
  }
}
