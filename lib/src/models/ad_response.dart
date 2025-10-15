// lib/src/models/ad_response.dart
import 'ad_unit.dart';

class AdResponse {
  final bool success;
  final String? message;
  final AdUnit? ad;
  final String? campaignId;
  final double? price;
  final String? currency;
  final DateTime? cacheExpiry;

  const AdResponse({
    required this.success,
    this.message,
    this.ad,
    this.campaignId,
    this.price,
    this.currency,
    this.cacheExpiry,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'ad': ad?.toJson(),
    'campaignId': campaignId,
    'price': price,
    'currency': currency,
    'cacheExpiry': cacheExpiry?.millisecondsSinceEpoch,
  };

  factory AdResponse.fromJson(Map<String, dynamic> json) {
    return AdResponse(
      success: json['success'] ?? false,
      message: json['message'],
      ad: json['ad'] != null ? AdUnit.fromJson(json['ad']) : null,
      campaignId: json['campaignId'],
      price: json['price']?.toDouble(),
      currency: json['currency'],
      cacheExpiry: json['cacheExpiry'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['cacheExpiry'])
          : null,
    );
  }
}
