// lib/src/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sdk_config.dart';
import '../models/ad_request.dart';
import '../models/ad_response.dart';
import '../exceptions/network_exception.dart';

class ApiService {
  final SDKConfig _config;
  late final http.Client _httpClient;

  bool _isAuthorized = false;
  DateTime? _authExpiry;

  ApiService(this._config) {
    _httpClient = http.Client();
  }

  /// Validate SDK with backend (with caching)
  Future<Map<String, dynamic>> validateSDK(Map<String, dynamic> deviceInfo) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if cached authorization exists and still valid
    final cachedAuth = prefs.getBool('sdk_authorized') ?? false;
    final expiryString = prefs.getString('sdk_auth_expiry');
    if (cachedAuth && expiryString != null) {
      final expiry = DateTime.tryParse(expiryString);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        _isAuthorized = true;
        _authExpiry = expiry;
        if (_config.enableLogging) {
          print('✅ SDK authorization loaded from cache (valid until $_authExpiry)');
        }
        return {'authorized': true, 'cached': true};
      }
    }

    // No valid cache, call backend
    try {
      final url = Uri.parse('${_config.baseUrl}/sdk/validate');
      final body = jsonEncode({
        'publisherId': _config.publisherId,
        'version': _config.version,
        'deviceInfo': deviceInfo,
      });

      if (_config.enableLogging) {
        print('🔐 Validating SDK with server...');
      }

      final response = await _httpClient
          .post(url, headers: _getHeaders(), body: body)
          .timeout(_config.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authorized = data['authorized'] == true;

        if (authorized) {
          _isAuthorized = true;
          _authExpiry = _parseExpiry(data['expiryDate']);
          await prefs.setBool('sdk_authorized', true);
          if (_authExpiry != null) {
            await prefs.setString('sdk_auth_expiry', _authExpiry!.toIso8601String());
          }
          if (_config.enableLogging) {
            print('✅ SDK authorized successfully (expires: $_authExpiry)');
          }
          return data;
        } else {
          throw NetworkException(data['message'] ?? 'SDK not authorized');
        }
      } else {
        throw NetworkException('SDK validation failed: ${response.statusCode}');
      }
    } on SocketException {
      throw NetworkException('No internet connection');
    } on TimeoutException {
      throw NetworkException('Request timeout');
    } catch (e) {
      throw NetworkException('SDK validation error: $e');
    }
  }

  /// Request ad from server (auto-retry once if fails)
  Future<AdResponse> requestAd(AdRequest request) async {
    if (!_isAuthorized) {
      throw NetworkException('SDK not authorized. Please call validateSDK() first.');
    }

    final url = Uri.parse('${_config.baseUrl}/ads/request');
    final body = jsonEncode({
      ...request.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    if (_config.enableLogging) {
      print('📡 Requesting Ad → $url');
    }

    try {
      final response = await _httpClient
          .post(url, headers: _getHeaders(), body: body)
          .timeout(_config.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final adResponse = AdResponse.fromJson(data);

        if (_config.enableLogging) {
         print('🎯 Ad Loaded: ${adResponse.ad?.format ?? 'unknown'}');
        }

        return adResponse;
      } else {
        throw NetworkException('Ad request failed: ${response.statusCode}');
      }
    } catch (e) {
      if (_config.enableLogging) {
        print('⚠️ Ad request error: $e — retrying once...');
      }
      // Retry once automatically after 1 second
      await Future.delayed(const Duration(seconds: 1));
      return await _retryAdRequest(request);
    }
  }

  /// Helper: Retry once
  Future<AdResponse> _retryAdRequest(AdRequest request) async {
    try {
      final url = Uri.parse('${_config.baseUrl}/ads/request');
      final response = await _httpClient
          .post(
            url,
            headers: _getHeaders(),
            body: jsonEncode({
              ...request.toJson(),
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            }),
          )
          .timeout(_config.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AdResponse.fromJson(data);
      } else {
        throw NetworkException('Ad request retry failed: ${response.statusCode}');
      }
    } catch (e) {
      throw NetworkException('Ad request failed after retry: $e');
    }
  }

  /// Track ad event (impression, click, close, reward)
  Future<void> trackEvent(String eventType, Map<String, dynamic> eventData) async {
    final url = Uri.parse('${_config.baseUrl}/ads/track');
    final body = jsonEncode({
      'eventType': eventType,
      'eventData': eventData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    try {
      await _httpClient.post(url, headers: _getHeaders(), body: body).timeout(_config.timeout);

      if (_config.enableLogging) {
        print('📊 Event tracked → $eventType');
      }
    } catch (e) {
      if (_config.enableLogging) {
        print('⚠️ Event tracking failed (ignored): $e');
      }
    }
  }

  /// Unified request headers
  Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_config.apiKey}',
        'X-Publisher-ID': _config.publisherId,
        'X-SDK-Version': _config.version,
        'X-Platform': Platform.isAndroid ? 'android' : 'ios',
      };

  /// Parse expiry string (ISO or timestamp)
  DateTime? _parseExpiry(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  void dispose() {
    _httpClient.close();
  }
}










// import 'package:flutter/material.dart';
// import '../models/sdk_config.dart';
// import '../models/ad_request.dart';
// import '../models/ad_response.dart';
// import '../models/ad_unit.dart';

// class ApiService {
//   final SDKConfig _config;

//   ApiService(this._config);

//   /// ✅ Mock SDK Validation (no server required)
//   Future<Map<String, dynamic>> validateSDK(Map<String, dynamic> deviceInfo) async {
//     if (_config.enableLogging) {
//       debugPrint('[API] 🔧 Mock SDK validation starting...');
//       debugPrint('[API] 📱 Device info: $deviceInfo');
//     }

//     await Future.delayed(const Duration(milliseconds: 200));

//     if (_config.enableLogging) {
//       debugPrint('[API] ✅ Mock SDK validation - SUCCESS');
//     }

//     return {
//       'valid': true,
//       'status': 'active',
//       'publisherStatus': 'active',
//       'settings': {
//         'cacheExpiry': 3600,
//         'requestTimeout': 10000,
//         'enableLogging': _config.enableLogging,
//       },
//       'mock': true,
//     };
//   }

//   /// ✅ Request Ad (returns static mock ad instead of API)
//   Future<AdResponse> requestAd(AdRequest request) async {
//     if (_config.enableLogging) {
//       debugPrint('[API] 🎭 Mock ad request for placement: ${request.placementId}');
//       debugPrint('[API] 📊 Request details: ${request.toJson()}');
//     }

//     await Future.delayed(const Duration(milliseconds: 300));

//     // Static ad images for mock environment
//     final staticAdImages = [
//       'https://picsum.photos/seed/ad1/600/200', // random but consistent banner
//       'https://picsum.photos/seed/ad2/600/200',
//       'https://picsum.photos/seed/ad3/600/200',
//     ];

//     // Pick a static image deterministically based on placement hash
//     final imageUrl = staticAdImages[request.placementId.hashCode.abs() % staticAdImages.length];

//     final mockAdId = 'mock_ad_${DateTime.now().millisecondsSinceEpoch}';
//     final mockAd = AdUnit(
//       id: mockAdId,
//       creativeUrl: imageUrl,
//       clickUrl: 'https://flutter.dev',
//       size: request.size,
//       format: 'banner',
//       title: 'Static Test Ad',
//       description: 'This static mock ad is served from local SDK configuration.',
//       callToAction: 'Learn More',
//       metadata: {
//         'placement': request.placementId,
//         'isMock': true,
//         'rewardType': 'points',
//         'rewardAmount': 10,
//         'created_at': DateTime.now().toIso8601String(),
//       },
//     );

//     final response = AdResponse(
//       success: true,
//       message: 'Static mock ad loaded successfully',
//       ad: mockAd,
//       campaignId: 'static_campaign_${DateTime.now().millisecondsSinceEpoch}',
//       price: 0.25,
//       currency: 'USD',
//       cacheExpiry: DateTime.now().add(const Duration(hours: 1)),
//     );

//     if (_config.enableLogging) {
//       debugPrint('[API] ✅ Mock ad response: Success');
//       debugPrint('[API] 🖼️ Ad Image URL: ${mockAd.creativeUrl}');
//     }

//     return response;
//   }

//   /// ✅ Track ad events (only logs in mock mode)
//   Future<void> trackEvent(String eventType, Map<String, dynamic> eventData) async {
//     if (_config.enableLogging) {
//       debugPrint('[API] 📊 Mock tracking event');
//       debugPrint('[API] 🎯 Event Type: $eventType');
//       debugPrint('[API] 📋 Event Data: $eventData');
//       debugPrint('[API] ⏰ Timestamp: ${DateTime.now().toIso8601String()}');
//     }
//   }

//   /// No HTTP client in mock mode
//   void dispose() {}
// }
