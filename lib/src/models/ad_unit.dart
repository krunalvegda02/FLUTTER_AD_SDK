// lib/src/models/ad_unit.dart
import 'ad_request.dart';

class AdUnit {
  final String id;
  final String creativeUrl;
  final String? clickUrl;
  final AdSize size;
  final String format;
  final String? title;
  final String? description;
  final String? callToAction;
  final Map<String, dynamic>? metadata;

  const AdUnit({
    required this.id,
    required this.creativeUrl,
    this.clickUrl,
    required this.size,
    required this.format,
    this.title,
    this.description,
    this.callToAction,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'creativeUrl': creativeUrl,
    'clickUrl': clickUrl,
    'size': size.toString(),
    'format': format,
    'title': title,
    'description': description,
    'callToAction': callToAction,
    'metadata': metadata,
  };

  factory AdUnit.fromJson(Map<String, dynamic> json) {
    return AdUnit(
      id: json['id'],
      creativeUrl: json['creativeUrl'],
      clickUrl: json['clickUrl'],
      size: _parseAdSize(json['size']),
      format: json['format'],
      title: json['title'],
      description: json['description'],
      callToAction: json['callToAction'],
      metadata: json['metadata'],
    );
  }

  static AdSize _parseAdSize(String size) {
    for (final adSize in AdSize.values) {
      if (adSize.toString() == size) {
        return adSize;
      }
    }
    return AdSize.banner300x250;
  }
}
