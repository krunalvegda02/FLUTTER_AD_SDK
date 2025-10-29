// lib/ad_platform_sdk.dart
library ad_platform_sdk;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/models/sdk_config.dart';
import 'src/models/ad_request.dart';
import 'src/models/ad_response.dart';
import 'src/services/api_service.dart';
import 'src/services/cache_service.dart';
import 'src/services/tracking_service.dart';
import 'src/utils/device_info.dart';
import 'src/exceptions/sdk_exception.dart';

export 'src/models/ad_request.dart';
export 'src/models/ad_response.dart';
export 'src/models/ad_unit.dart';
export 'src/widgets/banner_ad_widget.dart';
export 'src/widgets/interstitial_ad_widget.dart';
export 'src/widgets/rewarded_ad_widget.dart';

/// Main SDK class for Advertisement Platform
class AdPlatformSDK {
  static const String _version = '1.0.0';
  static AdPlatformSDK? _instance;
  static AdPlatformSDK get instance => _instance ??= AdPlatformSDK._internal();

  AdPlatformSDK._internal();

  bool _isInitialized = false;
  late SDKConfig _config;
  late ApiService _apiService;
  late CacheService _cacheService;
  late TrackingService _trackingService;
  late DeviceInfoService _deviceInfoService;

  /// Initialize the SDK with configuration
  Future<bool> initialize({
    required String publisherId,
    required String apiKey,
    String environment = 'production',
    bool enableLogging = false,
    Duration timeout = const Duration(seconds: 30),
    Map<String, dynamic>? additionalConfig,
  }) async {
    if (_isInitialized) {
      debugPrint('AdPlatformSDK: Already initialized');      return true;
    }

    try {
      // Validate required parameters
      if (publisherId.isEmpty || apiKey.isEmpty) {
        throw const SDKException('Publisher ID and API Key are required');
      }

      // Create configuration
      _config = SDKConfig(
        publisherId: publisherId,
        apiKey: apiKey,
        environment: environment,
        version: _version,
        enableLogging: enableLogging,
        timeout: timeout,
        additionalConfig: additionalConfig ?? {},
      );

      // Initialize services
      _apiService = ApiService(_config);
      _cacheService = CacheService();
      _trackingService = TrackingService(_config, _apiService);
      _deviceInfoService = DeviceInfoService();

      // Initialize device info
      await _deviceInfoService.initialize();

      // Validate SDK with server
      final validationResult = await _validateSDK();
      if (!validationResult) {
        throw const SDKException('SDK validation failed');
      }

      // Initialize cache
      await _cacheService.initialize();

      _isInitialized = true;

      if (_config.enableLogging) {
        debugPrint('AdPlatformSDK v$_version initialized successfully');
      }

      return true;
    } catch (e) {
      debugPrint('AdPlatformSDK initialization failed: $e');
      return false;
    }
  }

  /// Validate SDK with server
  Future<bool> _validateSDK() async {
    try {
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      final response = await _apiService.validateSDK(deviceInfo);
      return response['valid'] == true;
    } catch (e) {
      debugPrint('SDK validation error: $e');
      return false;
    }
  }

  /// Load a banner ad
  Future<AdResponse?> loadBannerAd(AdRequest request) async {
    _ensureInitialized();
    
    try {
      // Add device info to request
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      final enrichedRequest = request.copyWith(deviceInfo: deviceInfo);

      // Make ad request
      final response = await _apiService.requestAd(enrichedRequest);
      
      if (response.success && response.ad != null) {
        // Cache the ad response
        await _cacheService.cacheAdResponse(request.placementId, response);
        
        // Track ad request
        await _trackingService.trackAdRequest(enrichedRequest, response);
        
        return response;
      } else {
        // Try to serve from cache
        final cachedResponse = await _cacheService.getCachedAdResponse(request.placementId);
        if (cachedResponse != null) {
          debugPrint('Serving ad from cache');
          return cachedResponse;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      
      // Try to serve from cache as fallback
      final cachedResponse = await _cacheService.getCachedAdResponse(request.placementId);
      if (cachedResponse != null) {
        debugPrint('Serving ad from cache after error');
        return cachedResponse;
      }
      
      return null;
    }
  }

  /// Load an interstitial ad
  Future<AdResponse?> loadInterstitialAd(AdRequest request) async {
    _ensureInitialized();
    
    try {
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      final enrichedRequest = request.copyWith(
        deviceInfo: deviceInfo,
        adFormat: AdFormat.interstitial,
      );

      final response = await _apiService.requestAd(enrichedRequest);
      
      if (response.success && response.ad != null) {
        await _cacheService.cacheAdResponse(request.placementId, response);
        await _trackingService.trackAdRequest(enrichedRequest, response);
        return response;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      return null;
    }
  }

  /// Show an interstitial ad
  Future<bool> showInterstitialAd(String adId) async {
    _ensureInitialized();
    
    try {
      // Implementation for showing interstitial ad
      // This would involve platform-specific code
      final result = await _showInterstitialNative(adId);
      
      if (result) {
        await _trackingService.trackAdImpression(adId, AdFormat.interstitial);
      }
      
      return result;
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      return false;
    }
  }

  /// Load a rewarded ad
  Future<AdResponse?> loadRewardedAd(AdRequest request) async {
    _ensureInitialized();
    
    try {
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      final enrichedRequest = request.copyWith(
        deviceInfo: deviceInfo,
        adFormat: AdFormat.rewarded,
      );

      final response = await _apiService.requestAd(enrichedRequest);
      
      if (response.success && response.ad != null) {
        await _cacheService.cacheAdResponse(request.placementId, response);
        await _trackingService.trackAdRequest(enrichedRequest, response);
        return response;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      return null;
    }
  }

  /// Track ad impression
  Future<void> trackImpression(String adId, AdFormat format) async {
    _ensureInitialized();
    
    try {
      await _trackingService.trackAdImpression(adId, format);
    } catch (e) {
      debugPrint('Error tracking impression: $e');
    }
  }

  /// Track ad click
  Future<void> trackClick(String adId, AdFormat format) async {
    _ensureInitialized();
    
    try {
      await _trackingService.trackAdClick(adId, format);
    } catch (e) {
      debugPrint('Error tracking click: $e');
    }
  }

  /// Native method to show interstitial ad
  Future<bool> _showInterstitialNative(String adId) async {
    try {
      const platform = MethodChannel('com.yourplatform.adsdk/methods');
      final result = await platform.invokeMethod('showInterstitial', {'adId': adId});
      return result == true;
    } catch (e) {
      debugPrint('Error calling native showInterstitial: $e');
      return false;
    }
  }

  /// Ensure SDK is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const SDKException('SDK not initialized. Call AdPlatformSDK.instance.initialize() first.');
    }
  }

  /// Get SDK version
  String get version => _version;

  /// Check if SDK is initialized
  bool get isInitialized => _isInitialized;

  /// Get current configuration
  SDKConfig? get config => _isInitialized ? _config : null;

  /// Dispose SDK resources
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      await _cacheService.dispose();
      await _trackingService.dispose();
      _isInitialized = false;
      _instance = null;
      
      if (_config.enableLogging) {
        debugPrint('AdPlatformSDK disposed');
      }
    } catch (e) {
      debugPrint('Error disposing SDK: $e');
    }
  }
}
