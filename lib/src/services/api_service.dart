// // lib/src/services/api_service.dart
// import 'dart:convert';
// import 'dart:io';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import '../models/sdk_config.dart';
// import '../models/ad_request.dart';
// import '../models/ad_response.dart';
// import '../exceptions/network_exception.dart';
// import '../exceptions/sdk_exception.dart';


// class ApiService {
//   final SDKConfig _config;
//   late http.Client _httpClient;

//   ApiService(this._config) {
//     _httpClient = http.Client();
//   }

//   /// Validate SDK with server
//   Future<Map<String, dynamic>> validateSDK(Map<String, dynamic> deviceInfo) async {
//     try {
//       final url = Uri.parse('${_config.baseUrl}/sdk/validate');
//       final response = await _httpClient
//           .post(
//             url,
//             headers: _getHeaders(),
//             body: jsonEncode({
//               'publisherId': _config.publisherId,
//               'version': _config.version,
//               'deviceInfo': deviceInfo,
//             }),
//           )
//           .timeout(_config.timeout);

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw NetworkException('SDK validation failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (e is SocketException) {
//         throw NetworkException('No internet connection');
//       } else if (e is TimeoutException) {
//         throw NetworkException('Request timeout');
//       } else {
//         throw NetworkException('SDK validation error: $e');
//       }
//     }
//   }

//   /// Request an ad from the server
//   Future<AdResponse> requestAd(AdRequest request) async {
//     try {
//       final url = Uri.parse('${_config.baseUrl}/ads/request');
//       final requestBody = {
//         ...request.toJson(),
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       };

//       if (_config.enableLogging) {
//         print('Ad Request: ${jsonEncode(requestBody)}');
//       }

//       final response = await _httpClient
//           .post(
//             url,
//             headers: _getHeaders(),
//             body: jsonEncode(requestBody),
//           )
//           .timeout(_config.timeout);

//       if (_config.enableLogging) {
//         print('Ad Response: ${response.body}');
//       }

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         return AdResponse.fromJson(responseData);
//       } else {
//         throw NetworkException('Ad request failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (e is SocketException) {
//         throw NetworkException('No internet connection');
//       } else if (e is TimeoutException) {
//         throw NetworkException('Request timeout');
//       } else {
//         throw NetworkException('Ad request error: $e');
//       }
//     }
//   }

//   /// Track ad event (impression, click, etc.)
//   Future<void> trackEvent(String eventType, Map<String, dynamic> eventData) async {
//     try {
//       final url = Uri.parse('${_config.baseUrl}/ads/track');
//       final requestBody = {
//         'eventType': eventType,
//         'eventData': eventData,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       };

//       await _httpClient
//           .post(
//             url,
//             headers: _getHeaders(),
//             body: jsonEncode(requestBody),
//           )
//           .timeout(_config.timeout);

//     } catch (e) {
//       if (_config.enableLogging) {
//         print('Tracking error: $e');
//       }
//       // Don't throw tracking errors, just log them
//     }
//   }

//   /// Get request headers
//   Map<String, String> _getHeaders() {
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer ${_config.apiKey}',
//       'X-Publisher-ID': _config.publisherId,
//       'X-SDK-Version': _config.version,
//       'X-Platform': Platform.isAndroid ? 'android' : 'ios',
//     };
//   }

//   /// Dispose HTTP client
//   void dispose() {
//     _httpClient.close();
//   }
// }







import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/sdk_config.dart';
import '../models/ad_request.dart';
import '../models/ad_response.dart';
import '../models/ad_unit.dart';
import '../exceptions/sdk_exception.dart';

class ApiService {
  final SDKConfig _config;

  ApiService(this._config);

  /// ✅ Mock SDK Validation (no server required)
  Future<Map<String, dynamic>> validateSDK(Map<String, dynamic> deviceInfo) async {
    if (_config.enableLogging) {
      debugPrint('[API] 🔧 Mock SDK validation starting...');
      debugPrint('[API] 📱 Device info: $deviceInfo');
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (_config.enableLogging) {
      debugPrint('[API] ✅ Mock SDK validation - SUCCESS');
    }

    return {
      'valid': true,
      'status': 'active',
      'publisherStatus': 'active',
      'settings': {
        'cacheExpiry': 3600,
        'requestTimeout': 10000,
        'enableLogging': _config.enableLogging,
      },
      'mock': true,
    };
  }

  /// ✅ Request Ad (returns static mock ad instead of API)
  Future<AdResponse> requestAd(AdRequest request) async {
    if (_config.enableLogging) {
      debugPrint('[API] 🎭 Mock ad request for placement: ${request.placementId}');
      debugPrint('[API] 📊 Request details: ${request.toJson()}');
    }

    await Future.delayed(const Duration(milliseconds: 300));

    // Static ad images for mock environment
    final staticAdImages = [
      'https://picsum.photos/seed/ad1/600/200', // random but consistent banner
      'https://picsum.photos/seed/ad2/600/200',
      'https://picsum.photos/seed/ad3/600/200',
    ];

    // Pick a static image deterministically based on placement hash
    final imageUrl = staticAdImages[request.placementId.hashCode.abs() % staticAdImages.length];

    final mockAdId = 'mock_ad_${DateTime.now().millisecondsSinceEpoch}';
    final mockAd = AdUnit(
      id: mockAdId,
      creativeUrl: imageUrl,
      clickUrl: 'https://flutter.dev',
      size: request.size,
      format: 'banner',
      title: 'Static Test Ad',
      description: 'This static mock ad is served from local SDK configuration.',
      callToAction: 'Learn More',
      metadata: {
        'placement': request.placementId,
        'isMock': true,
        'rewardType': 'points',
        'rewardAmount': 10,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    final response = AdResponse(
      success: true,
      message: 'Static mock ad loaded successfully',
      ad: mockAd,
      campaignId: 'static_campaign_${DateTime.now().millisecondsSinceEpoch}',
      price: 0.25,
      currency: 'USD',
      cacheExpiry: DateTime.now().add(const Duration(hours: 1)),
    );

    if (_config.enableLogging) {
      debugPrint('[API] ✅ Mock ad response: Success');
      debugPrint('[API] 🖼️ Ad Image URL: ${mockAd.creativeUrl}');
    }

    return response;
  }

  /// ✅ Track ad events (only logs in mock mode)
  Future<void> trackEvent(String eventType, Map<String, dynamic> eventData) async {
    if (_config.enableLogging) {
      debugPrint('[API] 📊 Mock tracking event');
      debugPrint('[API] 🎯 Event Type: $eventType');
      debugPrint('[API] 📋 Event Data: $eventData');
      debugPrint('[API] ⏰ Timestamp: ${DateTime.now().toIso8601String()}');
    }
  }

  /// No HTTP client in mock mode
  void dispose() {}
}
