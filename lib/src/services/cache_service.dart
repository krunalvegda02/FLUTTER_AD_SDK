// lib/src/services/cache_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ad_response.dart';
import '../exceptions/sdk_exception.dart';

class CacheService {
  static const String _cacheKeyPrefix = 'ad_cache_';
  static const Duration _defaultCacheExpiry = Duration(hours: 1);
  
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('[Cache] ✅ Cache initialized successfully');
    } catch (e) {
      debugPrint('[Cache] ❌ Failed to initialize cache: $e');
      throw CacheException('Failed to initialize cache: $e');
    }
  }

  Future<void> cacheAdResponse(String placementId, AdResponse response) async {
    try {
      if (_prefs == null) await initialize();
      
      final cacheData = {
        'response': response.toJson(),
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'expiresAt': DateTime.now().add(_defaultCacheExpiry).millisecondsSinceEpoch,
      };

      final key = _getCacheKey(placementId);
      await _prefs!.setString(key, jsonEncode(cacheData));
      
      debugPrint('[Cache] ✅ Cached ad for placement: $placementId');
    } catch (e) {
      debugPrint('[Cache] ❌ Cache error: $e');
    }
  }

  Future<AdResponse?> getCachedAdResponse(String placementId) async {
    try {
      if (_prefs == null) await initialize();
      
      final key = _getCacheKey(placementId);
      final cacheString = _prefs!.getString(key);
      
      if (cacheString == null) {
        debugPrint('[Cache] ℹ️ No cache found for: $placementId');
        return null;
      }

      final cacheData = jsonDecode(cacheString);
      final expiresAt = cacheData['expiresAt'] as int;
      
      // Check if cache is expired
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await _prefs!.remove(key);
        debugPrint('[Cache] ⏰ Cache expired for: $placementId');
        return null;
      }

      debugPrint('[Cache] ✅ Serving from cache: $placementId');
      return AdResponse.fromJson(cacheData['response']);
    } catch (e) {
      debugPrint('[Cache] ❌ Cache read error: $e');
      return null;
    }
  }

  String _getCacheKey(String placementId) {
    return '$_cacheKeyPrefix$placementId';
  }

  Future<void> dispose() async {
    debugPrint('[Cache] 🗑️ Cache disposed');
  }
}
