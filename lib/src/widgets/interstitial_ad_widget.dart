import 'dart:async';
import 'package:flutter/material.dart';

class InterstitialAdWidget extends StatelessWidget {
  const InterstitialAdWidget._();

  /// Shows a fullscreen, professional-style interstitial ad.
  /// If [imageUrl] is null or fails to load, shows [fallbackImageUrl].
  static Future<bool> show({
    required BuildContext context,
    required String placementId,
    Map<String, dynamic>? targeting,
    // UI text
    String titleText = 'Sponsored Ad',
    String bodyText = 'Check out this offer!',
    String clickButtonText = 'Learn More',
    String closeButtonText = 'Close Ad',
    // Primary image URL for the ad
    String? imageUrl,
    // Fallback image URL if no ad or loading fails
    required String fallbackImageUrl,
    // Callbacks
    VoidCallback? onAdLoaded,
    ValueChanged<String>? onAdFailed,
    VoidCallback? onAdClicked,
    VoidCallback? onAdClosed,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      onAdLoaded?.call();
      final shown = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, _, __) => _InterstitialFullScreen(
          titleText: titleText,
          bodyText: bodyText,
          clickButtonText: clickButtonText,
          closeButtonText: closeButtonText,
          imageUrl: imageUrl,
          fallbackImageUrl: fallbackImageUrl,
          onAdClicked: onAdClicked,
          onAdClosed: onAdClosed,
        ),
      );
      return shown ?? false;
    } catch (e) {
      onAdFailed?.call(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) =>
      throw UnimplementedError('Use InterstitialAdWidget.show()');
}

class _InterstitialFullScreen extends StatelessWidget {
  final String titleText;
  final String bodyText;
  final String clickButtonText;
  final String closeButtonText;
  final String? imageUrl;
  final String fallbackImageUrl;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdClosed;

  const _InterstitialFullScreen({
    required this.titleText,
    required this.bodyText,
    required this.clickButtonText,
    required this.closeButtonText,
    this.imageUrl,
    required this.fallbackImageUrl,
    this.onAdClicked,
    this.onAdClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(children: [
          // Top bar
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titleText,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                    onAdClosed?.call();
                  },
                  child: Text(closeButtonText, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ),
              ],
            ),
          ),

          // Main content with fallback
          Expanded(
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Image.network(fallbackImageUrl, fit: BoxFit.cover),
                  )
                : Image.network(fallbackImageUrl, fit: BoxFit.cover, width: double.infinity),
          ),

          // Body text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(bodyText,
                style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () {
                  onAdClicked?.call();
                  Navigator.of(context).pop(true);
                  onAdClosed?.call();
                },
                child: Text(clickButtonText, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
