import 'package:flutter/material.dart';

class RewardedAdWidget extends StatelessWidget {
  final String placementId;
  final Map<String, dynamic>? targeting;
  final VoidCallback? onAdLoaded;
  final ValueChanged<String>? onAdFailed;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdClosed;
  final void Function(String type, int amount)? onRewardEarned;

  // New parameter to control showing video or image
  final bool showVideo;
  final String? imageUrl;

  const RewardedAdWidget({
    Key? key,
    required this.placementId,
    this.targeting,
    this.onAdLoaded,
    this.onAdFailed,
    this.onAdClicked,
    this.onAdClosed,
    this.onRewardEarned,
    this.showVideo = true,  // Defaults to showing video placeholder
    this.imageUrl,          // Optional image URL if showVideo is false
  }) : super(key: key);

  static Future<bool> show({
    required BuildContext context,
    required String placementId,
    Map<String, dynamic>? targeting,
    VoidCallback? onAdLoaded,
    ValueChanged<String>? onAdFailed,
    VoidCallback? onAdClicked,
    VoidCallback? onAdClosed,
    void Function(String type, int amount)? onRewardEarned,
    bool showVideo = true,
    String? imageUrl,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    onAdLoaded?.call();

    bool result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Rewarded Ad'),
            content: SizedBox(
              height: 250,
              child: showVideo
                  ? _buildVideoPlaceholder()
                  : _buildImagePlaceholder(imageUrl),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  onAdClicked?.call();
                  onRewardEarned?.call('coins', 50);
                  Navigator.of(context).pop(true);
                  onAdClosed?.call();
                },
                child: const Text('Claim Reward'),
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

  static Widget _buildVideoPlaceholder() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: const Center(
            child: Icon(
              Icons.videocam,
              color: Colors.white,
              size: 100,
            ),
          ),
        ),
        const Positioned(
          bottom: 8,
          right: 8,
          child: Text(
            'Mock Video Ad',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  static Widget _buildImagePlaceholder(String? imageUrl) {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: imageUrl != null
            ? Image.network(imageUrl, fit: BoxFit.contain)
            : const Text(
                'Mock Image Ad',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('Use RewardedAdWidget.show() instead.');
  }
}
