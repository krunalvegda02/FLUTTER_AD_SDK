// lib/src/widgets/banner_ad_widget.dart
// import 'package:flutter/material.dart';
// import 'package:ad_platform_sdk/ad_platform_sdk.dart';

// import '../models/ad_request.dart';
// import '../models/ad_response.dart';

// class BannerAdWidget extends StatefulWidget {
//   final String placementId;
//   final AdSize size;
//   final Map<String, dynamic> targeting;
//   final Function(String adId)? onAdLoaded;
//   final Function(String error)? onAdFailed;
//   final Function(String adId)? onAdClicked;
//   final Widget? loadingWidget;
//   final Widget? errorWidget;

//   const BannerAdWidget({
//     Key? key,
//     required this.placementId,
//     required this.size,
//     this.targeting = const {},
//     this.onAdLoaded,
//     this.onAdFailed,
//     this.onAdClicked,
//     this.loadingWidget,
//     this.errorWidget,
//   }) : super(key: key);

//   @override
//   State<BannerAdWidget> createState() => _BannerAdWidgetState();
// }

// class _BannerAdWidgetState extends State<BannerAdWidget> {
//   AdResponse? _adResponse;
//   bool _isLoading = true;
//   String? _error;
//   bool _isDisposed = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadAd();
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     super.dispose();
//   }

//   Future<void> _loadAd() async {
//     if (_isDisposed) return;

//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final adRequest = AdRequest(
//         placementId: widget.placementId,
//         size: widget.size,
//         adFormat: AdFormat.banner,
//         targeting: widget.targeting,
//       );

//       final response = await AdPlatformSDK.instance.loadBannerAd(adRequest);

//       if (_isDisposed) return;

//       if (response != null && response.success && response.ad != null) {
//         setState(() {
//           _adResponse = response;
//           _isLoading = false;
//         });
//         widget.onAdLoaded?.call(response.ad!.id);
//       } else {
//         final errorMessage = response?.message ?? 'Failed to load ad';
//         setState(() {
//           _error = errorMessage;
//           _isLoading = false;
//         });
//         widget.onAdFailed?.call(errorMessage);
//       }
//     } catch (e) {
//       if (_isDisposed) return;

//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//       widget.onAdFailed?.call(e.toString());
//     }
//   }

//   void _handleAdTap() {
//     if (_adResponse?.ad != null) {
//       // Track click
//       AdPlatformSDK.instance.trackClick(_adResponse!.ad!.id, AdFormat.banner);
      
//       // Notify callback
//       widget.onAdClicked?.call(_adResponse!.ad!.id);
      
//       // Open click URL if available
//       if (_adResponse!.ad!.clickUrl != null) {
//         // Use url_launcher or platform-specific code to open URL
//         _openUrl(_adResponse!.ad!.clickUrl!);
//       }
//     }
//   }

//   Future<void> _openUrl(String url) async {
//     // Implementation depends on url_launcher package
//     // or platform-specific code
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: widget.size.width.toDouble(),
//       height: widget.size.height.toDouble(),
//       child: _buildContent(),
//     );
//   }

//   Widget _buildContent() {
//     if (_isLoading) {
//       return widget.loadingWidget ?? _buildDefaultLoading();
//     }

//     if (_error != null) {
//       return widget.errorWidget ?? _buildDefaultError();
//     }

//     if (_adResponse?.ad != null) {
//       return _buildAdContent();
//     }

//     return _buildDefaultError();
//   }

//   Widget _buildDefaultLoading() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey,
//         border: Border.all(color: Colors.grey!),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: const Center(
//         child: CircularProgressIndicator(strokeWidth: 2),
//       ),
//     );
//   }

//   Widget _buildDefaultError() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey,
//         border: Border.all(color: Colors.grey!),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.grey, size: 24),
//             const SizedBox(height: 4),
//             Text(
//               'Ad Load Error',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (_error != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   _error!,
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 10,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAdContent() {
//     final ad = _adResponse!.ad!;
    
//     return GestureDetector(
//       onTap: _handleAdTap,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: Stack(
//             children: [
//               // Ad image
//               Image.network(
//                 ad.creativeUrl,
//                 width: widget.size.width.toDouble(),
//                 height: widget.size.height.toDouble(),
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return _buildDefaultLoading();
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   return _buildDefaultError();
//                 },
//               ),
              
//               // Ad label
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                   child: const Text(
//                     'Ad',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 8,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../ad_platform_sdk.dart';
import '../models/ad_request.dart';
import '../models/ad_response.dart';
import '../models/ad_unit.dart';

class BannerAdWidget extends StatefulWidget {
  /// Required: Unique placement ID
  final String placementId;

  /// Ad size (width x height)
  final AdSize size;

  /// Ad targeting parameters
  final Map<String, dynamic> targeting;

  /// Optional callbacks
  final VoidCallback? onAdLoaded;
  final ValueChanged<String>? onAdFailed;
  final VoidCallback? onAdClicked;

  /// UI customization (all optional)
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Duration refreshInterval;
  final Color borderColor;
  final double borderRadius;
  final List<BoxShadow> boxShadow;
  final Color labelBackgroundColor;
  final TextStyle labelTextStyle;

  const BannerAdWidget({
    Key? key,
    required this.placementId,
    required this.size,
    this.targeting = const {},
    this.onAdLoaded,
    this.onAdFailed,
    this.onAdClicked,
    this.loadingWidget,
    this.errorWidget,
    this.refreshInterval = const Duration(seconds: 60),
    this.borderColor = Colors.grey,
    this.borderRadius = 8.0,
    this.boxShadow = const [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
    ],
    this.labelBackgroundColor = Colors.black54,
    this.labelTextStyle = const TextStyle(color: Colors.white, fontSize: 8),
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  AdResponse? _adResponse;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAd();
    _scheduleRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _scheduleRefresh() {
    _refreshTimer = Timer.periodic(widget.refreshInterval, (_) {
      if (mounted) _loadAd();
    });
  }

  Future<void> _loadAd() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final request = AdRequest(
        placementId: widget.placementId,
        size: widget.size,
        adFormat: AdFormat.banner,
        targeting: widget.targeting,
      );
      final response = await AdPlatformSDK.instance.loadBannerAd(request);

      if (!mounted) return;
      if (response != null && response.success && response.ad != null) {
        setState(() {
          _adResponse = response;
          _isLoading = false;
        });
        AdPlatformSDK.instance.trackImpression(response.ad!.id, AdFormat.banner);
        widget.onAdLoaded?.call();
      } else {
        throw Exception(response?.message ?? 'No ad available');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      widget.onAdFailed?.call(e.toString());
    }
  }

  Future<void> _handleClick() async {
    final url = _adResponse?.ad?.clickUrl;
    if (url != null) {
      AdPlatformSDK.instance.trackClick(_adResponse!.ad!.id, AdFormat.banner);
      widget.onAdClicked?.call();
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      width: widget.size.width.toDouble(),
      height: widget.size.height.toDouble(),
      child: _isLoading
          ? widget.loadingWidget ?? _buildDefaultLoading()
          : (_errorMessage != null
              ? widget.errorWidget ?? _buildDefaultError()
              : _buildAdContent()),
    );
  }

  Widget _buildDefaultLoading() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor),
      ),
      child: const Center(
        child: Text('Ad Unavailable', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildAdContent() {
    final ad = _adResponse!.ad!;
    return GestureDetector(
      onTap: _handleClick,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.boxShadow,
        ),
        child: Stack(children: [
          CachedNetworkImage(
            imageUrl: ad.creativeUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildDefaultLoading(),
            errorWidget: (_, __, ___) => _buildDefaultError(),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: widget.labelBackgroundColor,
                // borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Ad', style: widget.labelTextStyle),
            ),
          ),
        ]),
      ),
    );
  }
}
