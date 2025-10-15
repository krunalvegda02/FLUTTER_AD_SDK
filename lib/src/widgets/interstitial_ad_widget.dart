import 'package:flutter/material.dart';

class InterstitialAdWidget extends StatelessWidget {
  final String placementId;
  final Map<String, dynamic>? targeting;
  final VoidCallback? onAdLoaded;
  final ValueChanged<String>? onAdFailed;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdClosed;

  const InterstitialAdWidget({
    Key? key,
    required this.placementId,
    this.targeting,
    this.onAdLoaded,
    this.onAdFailed,
    this.onAdClicked,
    this.onAdClosed,
  }) : super(key: key);

  static Future<bool> show({
    required BuildContext context,
    required String placementId,
    Map<String, dynamic>? targeting,
    VoidCallback? onAdLoaded,
    ValueChanged<String>? onAdFailed,
    VoidCallback? onAdClicked,
    VoidCallback? onAdClosed,
  }) async {
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 1));
    onAdLoaded?.call();

    // Show mock ad dialog
    bool result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Interstitial Ad'),
            content: Text('Interstitial Ad for placement: $placementId'),
            actions: [
              TextButton(
                onPressed: () {
                  onAdClicked?.call();
                  Navigator.of(context).pop(true);
                  onAdClosed?.call();
                },
                child: const Text('Click Ad'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  onAdClosed?.call();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ) ??
        false;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Must use the static `show` method instead
    throw UnimplementedError('Use InterstitialAdWidget.show()');
  }
}
