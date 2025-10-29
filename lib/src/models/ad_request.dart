// lib/src/models/ad_request.dart
enum AdFormat { banner, interstitial, rewarded, native }

enum AdSize {
  banner320x50(320, 50),
  banner300x250(300, 250),
  banner728x90(728, 90),
  interstitial320x480(320, 480),
  rewardedVideo(300, 300);

  const AdSize(this.width, this.height);
  final int width;
  final int height;

  @override
  String toString() => '${width}x$height';
}

class AdRequest {
  final String placementId;
  final AdSize size;
  final AdFormat adFormat;
  final Map<String, dynamic> targeting;
  final String? userId;
  final Map<String, String>? customParams;
  final Map<String, dynamic>? deviceInfo;

  const AdRequest({
    required this.placementId,
    required this.size,
    required this.adFormat,
    this.targeting = const {},
    this.userId,
    this.customParams,
    this.deviceInfo,
  });

  AdRequest copyWith({
    String? placementId,
    AdSize? size,
    AdFormat? adFormat,
    Map<String, dynamic>? targeting,
    String? userId,
    Map<String, String>? customParams,
    Map<String, dynamic>? deviceInfo,
  }) {
    return AdRequest(
      placementId: placementId ?? this.placementId,
      size: size ?? this.size,
      adFormat: adFormat ?? this.adFormat,
      targeting: targeting ?? this.targeting,
      userId: userId ?? this.userId,
      customParams: customParams ?? this.customParams,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  Map<String, dynamic> toJson() => {
    'placementId': placementId,
    'size': size.toString(),
    'adFormat': adFormat.name,
    'targeting': targeting,
    'userId': userId,
    'customParams': customParams,
    'deviceInfo': deviceInfo,
  };

  factory AdRequest.fromJson(Map<String, dynamic> json) {
    return AdRequest(
      placementId: json['placementId'],
      size: _parseAdSize(json['size']),
      adFormat: AdFormat.values.firstWhere(
        (e) => e.name == json['adFormat'],
        orElse: () => AdFormat.banner,
      ),
      targeting: Map<String, dynamic>.from(json['targeting'] ?? {}),
      userId: json['userId'],
      customParams: json['customParams']?.cast<String, String>(),
      deviceInfo: json['deviceInfo'],
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
