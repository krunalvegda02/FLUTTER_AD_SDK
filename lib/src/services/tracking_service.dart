// lib/src/services/tracking_service.dart
import 'dart:async';
import 'dart:collection';
import '../models/sdk_config.dart';
import '../models/ad_request.dart';
import '../models/ad_response.dart';
import 'api_service.dart';

class TrackingService {
  final SDKConfig _config;
  final ApiService _apiService;
  final Queue<Map<String, dynamic>> _eventQueue = Queue();
  Timer? _flushTimer;
  bool _isDisposed = false;

  TrackingService(this._config, this._apiService) {
    _startPeriodicFlush();
  }

  void _startPeriodicFlush() {
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _flushEvents();
    });
  }

  Future<void> trackAdRequest(AdRequest request, AdResponse response) async {
    if (_isDisposed) return;

    final event = {
      'event_type': 'ad_request',
      'placement_id': request.placementId,
      'ad_format': request.adFormat.name,
      'ad_size': request.size.toString(),
      'campaign_id': response.campaignId,
      'ad_id': response.ad?.id,
      'success': response.success,
      'timestamp': DateTime.now().toIso8601String(),
      'targeting': request.targeting,
      'device_info': request.deviceInfo,
    };

    _enqueueEvent(event);
  }

  Future<void> trackAdImpression(String adId, AdFormat format) async {
    if (_isDisposed) return;

    final event = {
      'event_type': 'impression',
      'ad_id': adId,
      'ad_format': format.name,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _enqueueEvent(event);
  }

  Future<void> trackAdClick(String adId, AdFormat format) async {
    if (_isDisposed) return;

    final event = {
      'event_type': 'click',
      'ad_id': adId,
      'ad_format': format.name,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _enqueueEvent(event);
  }

  Future<void> trackAdError(String placementId, String error, AdFormat format) async {
    if (_isDisposed) return;

    final event = {
      'event_type': 'ad_error',
      'placement_id': placementId,
      'ad_format': format.name,
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _enqueueEvent(event);
  }

  void _enqueueEvent(Map<String, dynamic> event) {
    _eventQueue.add(event);
    
    // Flush immediately for important events
    if (event['event_type'] == 'click' || event['event_type'] == 'impression') {
      _flushEvents();
    }
  }

  Future<void> _flushEvents() async {
    if (_isDisposed || _eventQueue.isEmpty) return;

    final eventsToSend = <Map<String, dynamic>>[];
    while (_eventQueue.isNotEmpty && eventsToSend.length < 100) {
      eventsToSend.add(_eventQueue.removeFirst());
    }

    if (eventsToSend.isEmpty) return;

    try {
      await _apiService.trackEvent('batch', {
        'events': eventsToSend,
        'publisher_id': _config.publisherId,
        'sdk_version': _config.version,
      });

      if (_config.enableLogging) {
        print('Flushed ${eventsToSend.length} tracking events');
      }
    } catch (e) {
      if (_config.enableLogging) {
        print('Failed to flush tracking events: $e');
      }
      
      // Re-queue events on failure (up to 3 retries)
      for (final event in eventsToSend) {
        event['retry_count'] = (event['retry_count'] ?? 0) + 1;
        if ((event['retry_count'] as int) <= 3) {
          _eventQueue.addFirst(event);
        }
      }
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _flushTimer?.cancel();
    
    // Final flush of remaining events
    if (_eventQueue.isNotEmpty) {
      await _flushEvents();
    }
  }
}



// // lib/src/services/tracking_service.dart
// import 'dart:async';
// import 'dart:collection';
// import 'package:flutter/material.dart';
// import '../models/sdk_config.dart';
// import '../models/ad_request.dart';
// import '../models/ad_response.dart';
// import 'api_service.dart';

// class TrackingService {
//   final SDKConfig _config;
//   final ApiService _apiService;
//   final Queue<Map<String, dynamic>> _eventQueue = Queue();
//   Timer? _flushTimer;
//   bool _isDisposed = false;

//   TrackingService(this._config, this._apiService) {
//     _startPeriodicFlush();
//     debugPrint('[Tracking] ✅ Tracking service initialized');
//   }

//   void _startPeriodicFlush() {
//     _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) {
//       _flushEvents();
//     });
//   }

//   Future<void> trackAdRequest(AdRequest request, AdResponse response) async {
//     if (_isDisposed) return;

//     final event = {
//       'event_type': 'ad_request',
//       'placement_id': request.placementId,
//       'ad_format': request.adFormat.name,
//       'ad_size': request.size.toString(),
//       'campaign_id': response.campaignId,
//       'ad_id': response.ad?.id,
//       'success': response.success,
//       'timestamp': DateTime.now().toIso8601String(),
//       'targeting': request.targeting,
//     };

//     _enqueueEvent(event);
//   }

//   Future<void> trackAdImpression(String adId, AdFormat format) async {
//     if (_isDisposed) return;

//     final event = {
//       'event_type': 'impression',
//       'ad_id': adId,
//       'ad_format': format.name,
//       'timestamp': DateTime.now().toIso8601String(),
//     };

//     _enqueueEvent(event);
//   }

//   Future<void> trackAdClick(String adId, AdFormat format) async {
//     if (_isDisposed) return;

//     final event = {
//       'event_type': 'click',
//       'ad_id': adId,
//       'ad_format': format.name,
//       'timestamp': DateTime.now().toIso8601String(),
//     };

//     _enqueueEvent(event);
//   }

//   void _enqueueEvent(Map<String, dynamic> event) {
//     _eventQueue.add(event);
    
//     if (_config.enableLogging) {
//       debugPrint('[Tracking] 📊 Event queued: ${event['event_type']}');
//     }
    
//     // Flush immediately for important events
//     if (event['event_type'] == 'click' || event['event_type'] == 'impression') {
//       _flushEvents();
//     }
//   }

//   Future<void> _flushEvents() async {
//     if (_isDisposed || _eventQueue.isEmpty) return;

//     final eventsToSend = <Map<String, dynamic>>[];
//     while (_eventQueue.isNotEmpty && eventsToSend.length < 10) {
//       eventsToSend.add(_eventQueue.removeFirst());
//     }

//     if (eventsToSend.isEmpty) return;

//     try {
//       await _apiService.trackEvent('batch', {
//         'events': eventsToSend,
//         'publisher_id': _config.publisherId,
//         'sdk_version': _config.version,
//       });

//       if (_config.enableLogging) {
//         debugPrint('[Tracking] ✅ Flushed ${eventsToSend.length} tracking events');
//       }
//     } catch (e) {
//       if (_config.enableLogging) {
//         debugPrint('[Tracking] ❌ Failed to flush tracking events: $e');
//       }
//     }
//   }

//   Future<void> dispose() async {
//     _isDisposed = true;
//     _flushTimer?.cancel();
    
//     if (_eventQueue.isNotEmpty) {
//       await _flushEvents();
//     }
    
//     debugPrint('[Tracking] 🗑️ Tracking service disposed');
//   }
// }
