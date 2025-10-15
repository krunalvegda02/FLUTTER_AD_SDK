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








// lib/src/widgets/banner_ad_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ad_request.dart';
import '../models/ad_response.dart';
import '../models/ad_unit.dart';
import '../../ad_platform_sdk.dart';

class BannerAdWidget extends StatefulWidget {
  final String placementId;
  final AdSize size;
  final Map<String, dynamic> targeting;
  final VoidCallback? onAdLoaded;
  final ValueChanged<String>? onAdFailed;
  final VoidCallback? onAdClicked;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Duration? refreshInterval;

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
    this.refreshInterval,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  AdResponse? _adResponse;
  bool _isLoading = true;
  String? _errorMessage;
  bool _disposed = false;
  Timer? _refreshTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAd();
    _setupRefreshTimer();
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _setupRefreshTimer() {
    if (widget.refreshInterval != null) {
      _refreshTimer = Timer.periodic(widget.refreshInterval!, (_) {
        if (!_disposed && mounted) {
          _loadAd();
        }
      });
    }
  }

  Future<void> _loadAd() async {
    if (_disposed) return;

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

      if (_disposed) return;

      if (response != null && response.success && response.ad != null) {
        setState(() {
          _adResponse = response;
          _isLoading = false;
        });

        _trackImpression();
        widget.onAdLoaded?.call();
      } else {
        final errorMessage = response?.message ?? 'Failed to load ad';
        setState(() {
          _errorMessage = errorMessage;
          _isLoading = false;
        });
        widget.onAdFailed?.call(errorMessage);
      }
    } catch (e) {
      if (_disposed) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      widget.onAdFailed?.call(e.toString());
    }
  }

  void _trackImpression() {
    if (_adResponse?.ad != null) {
      AdPlatformSDK.instance.trackImpression(_adResponse!.ad!.id, AdFormat.banner);
    }
  }

  void _handleClick() async {
    if (_adResponse?.ad?.clickUrl != null) {
      AdPlatformSDK.instance.trackClick(_adResponse!.ad!.id, AdFormat.banner);
      widget.onAdClicked?.call();

      try {
        final url = Uri.parse(_adResponse!.ad!.clickUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Failed to launch URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SizedBox(
      width: widget.size.width.toDouble(),
      height: widget.size.height.toDouble(),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return widget.loadingWidget ?? _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return widget.errorWidget ?? _buildErrorWidget();
    }

    if (_adResponse?.ad != null) {
      return _buildAdWidget();
    }

    return _buildErrorWidget();
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey!),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey!,
         style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: Colors.grey, size: 16),
            const SizedBox(height: 4),
            Text(
              'Ad Unavailable',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdWidget() {
    final ad = _adResponse!.ad!;

    return GestureDetector(
      onTap: _handleClick,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: ad.creativeUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildLoadingWidget(),
                errorWidget: (context, url, error) => _buildErrorWidget(),
                memCacheWidth: widget.size.width,
                memCacheHeight: widget.size.height,
              ),
              
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


