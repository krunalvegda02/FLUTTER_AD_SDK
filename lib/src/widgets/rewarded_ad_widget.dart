import 'dart:async';
import 'package:flutter/material.dart';

class RewardedAdWidget extends StatelessWidget {
  final String placementId;
  final Map<String, dynamic>? targeting;
  final VoidCallback? onAdLoaded;
  final ValueChanged<String>? onAdFailed;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdClosed;
  final void Function(String type, int amount)? onRewardEarned;

  const RewardedAdWidget({
    Key? key,
    required this.placementId,
    this.targeting,
    this.onAdLoaded,
    this.onAdFailed,
    this.onAdClicked,
    this.onAdClosed,
    this.onRewardEarned,
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
    int adDurationSeconds = 8,
    int rewardAmount = 50,
    String rewardType = "coins",
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      barrierLabel: 'Rewarded Ad',
      pageBuilder: (context, _, __) => _RewardedAdFullScreen(
        placementId: placementId,
        adDurationSeconds: adDurationSeconds,
        onAdLoaded: onAdLoaded,
        onAdClicked: onAdClicked,
        onAdClosed: onAdClosed,
        onRewardEarned: onRewardEarned,
        rewardAmount: rewardAmount,
        rewardType: rewardType,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) =>
      throw UnimplementedError('Use RewardedAdWidget.show() instead.');
}

// --- Professional Fullscreen Rewarded Ad ---
class _RewardedAdFullScreen extends StatefulWidget {
  final String placementId;
  final int adDurationSeconds;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdClosed;
  final void Function(String type, int amount)? onRewardEarned;
  final int rewardAmount;
  final String rewardType;

  const _RewardedAdFullScreen({
    Key? key,
    required this.placementId,
    required this.adDurationSeconds,
    this.onAdLoaded,
    this.onAdClicked,
    this.onAdClosed,
    this.onRewardEarned,
    this.rewardAmount = 50,
    this.rewardType = "coins",
  }) : super(key: key);

  @override
  State<_RewardedAdFullScreen> createState() => _RewardedAdFullScreenState();
}

class _RewardedAdFullScreenState extends State<_RewardedAdFullScreen> {
  double progress = 0.0;
  late Timer timer;
  bool closeButtonVisible = false;
  bool rewardClaimed = false;
  int remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.adDurationSeconds;
    widget.onAdLoaded?.call();
    timer = Timer.periodic(const Duration(milliseconds: 80), _tick);
  }

  void _tick(Timer t) {
    if (!mounted) return;
    setState(() {
      progress += 1.0 / (widget.adDurationSeconds * 12.5);
      remainingSeconds = ((1.0 - progress) * widget.adDurationSeconds).ceil();
      
      // Show close button after 80% watched
      if (progress >= 0.8 && !closeButtonVisible) {
        closeButtonVisible = true;
      }
      
      // Auto-complete at 100%
      if (progress >= 1.0) {
        progress = 1.0;
        remainingSeconds = 0;
        timer.cancel();
      }
    });
  }

  void _handleClose() {
    timer.cancel();
    
    // If user watched 80%+, grant reward
    if (progress >= 0.8 && !rewardClaimed) {
      rewardClaimed = true;
      widget.onRewardEarned?.call(widget.rewardType, widget.rewardAmount);
      widget.onAdClicked?.call();
      
      // Show confirmation dialog
      _showRewardDialog();
    } else {
      // Close without reward
      Navigator.of(context).pop(false);
      widget.onAdClosed?.call();
    }
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Reward Earned!'),
          ],
        ),
        content: Text(
          'You earned ${widget.rewardAmount} ${widget.rewardType}!',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Close ad
              widget.onAdClosed?.call();
            },
            child: const Text('COLLECT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (timer.isActive) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Mock video player section
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: Colors.white70,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Video Ad Playing',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Top bar with timer and close button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            remainingSeconds > 0 ? '${remainingSeconds}s' : 'Done',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Close button (appears after 80%)
                    if (closeButtonVisible)
                      GestureDetector(
                        onTap: _handleClose,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.black87, size: 20),
                        ),
                      )
                    else
                      const SizedBox(width: 36),
                  ],
                ),
              ),
            ),

            // Bottom reward info card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        minHeight: 5,
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Reward card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.card_giftcard,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Watch to earn',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.rewardAmount} ${widget.rewardType}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (progress >= 1.0)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Instruction text
                    Text(
                      progress >= 0.8
                          ? 'Tap × to claim your reward'
                          : 'Watch the full video to earn rewards',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Ad label (required by ad policies)
            const Positioned(
              top: 60,
              left: 16,
              child: Text(
                'AD',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


























// import 'dart:async';
// import 'package:flutter/material.dart';

// class RewardedAdWidget extends StatelessWidget {
//   const RewardedAdWidget._(); // Private constructor—use static show()

//   /// Displays a fullscreen rewarded ad with dynamic content.
//   ///
//   /// All parameters are supplied by the caller:
//   /// - `placementId`: Unique ad placement
//   /// - `rewardAmount`, `rewardType`: Reward details
//   /// - `titleText`: Dialog title
//   /// - `claimButtonText`: Text for the claim button
//   /// - `closeButtonTooltip`: Tooltip for skip/close button
//   /// - `watchingInstruction`, `claimInstruction`: Instruction texts
//   /// - `adDurationSeconds`: Mock video duration
//   /// - `closeThreshold`: Fraction of video after which skip appears (0.0–1.0)
//   /// - Callbacks for ad lifecycle and reward
//   static Future<bool> show({
//     required BuildContext context,
//     required String placementId,
//     Map<String, dynamic>? targeting,
//     // Reward settings
//     int rewardAmount = 50,
//     String rewardType = 'coins',
//     // UI text
//     String titleText = 'Rewarded Ad',
//     String claimButtonText = 'Claim Reward',
//     String closeButtonTooltip = 'Skip Ad',
//     String watchingInstruction = 'Watch the full video to earn rewards',
//     String claimInstruction = 'Tap × to claim your reward',
//     // Timing
//     int adDurationSeconds = 8,
//     double closeThreshold = 0.8,
//     // Callbacks
//     VoidCallback? onAdLoaded,
//     ValueChanged<String>? onAdFailed,
//     VoidCallback? onAdClicked,
//     VoidCallback? onAdClosed,
//     void Function(String type, int amount)? onRewardEarned,
//   }) async {
//     // Show a general dialog for fullscreen ad
//     final shown = await showGeneralDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black87,
//       barrierLabel: 'Rewarded Ad',
//       pageBuilder: (context, _, __) => _RewardedAdFullScreen(
//         placementId: placementId,
//         rewardAmount: rewardAmount,
//         rewardType: rewardType,
//         titleText: titleText,
//         claimButtonText: claimButtonText,
//         closeButtonTooltip: closeButtonTooltip,
//         watchingInstruction: watchingInstruction,
//         claimInstruction: claimInstruction,
//         adDurationSeconds: adDurationSeconds,
//         closeThreshold: closeThreshold,
//         onAdLoaded: onAdLoaded,
//         onAdClicked: onAdClicked,
//         onAdClosed: onAdClosed,
//         onRewardEarned: onRewardEarned,
//       ),
//     );
//     return shown ?? false;
//   }

//   @override
//   Widget build(BuildContext context) =>
//       throw UnimplementedError('Use RewardedAdWidget.show() instead.');
// }

// class _RewardedAdFullScreen extends StatefulWidget {
//   final String placementId;
//   final int rewardAmount;
//   final String rewardType;
//   final String titleText;
//   final String claimButtonText;
//   final String closeButtonTooltip;
//   final String watchingInstruction;
//   final String claimInstruction;
//   final int adDurationSeconds;
//   final double closeThreshold;
//   final VoidCallback? onAdLoaded;
//   final VoidCallback? onAdClicked;
//   final VoidCallback? onAdClosed;
//   final void Function(String type, int amount)? onRewardEarned;

//   const _RewardedAdFullScreen({
//     Key? key,
//     required this.placementId,
//     required this.rewardAmount,
//     required this.rewardType,
//     required this.titleText,
//     required this.claimButtonText,
//     required this.closeButtonTooltip,
//     required this.watchingInstruction,
//     required this.claimInstruction,
//     required this.adDurationSeconds,
//     required this.closeThreshold,
//     this.onAdLoaded,
//     this.onAdClicked,
//     this.onAdClosed,
//     this.onRewardEarned,
//   }) : super(key: key);

//   @override
//   State<_RewardedAdFullScreen> createState() => _RewardedAdFullScreenState();
// }

// class _RewardedAdFullScreenState extends State<_RewardedAdFullScreen> {
//   double progress = 0.0;
//   late Timer timer;
//   bool closeButtonVisible = false;
//   bool rewardClaimed = false;
//   int remainingSeconds = 0;

//   @override
//   void initState() {
//     super.initState();
//     remainingSeconds = widget.adDurationSeconds;
//     widget.onAdLoaded?.call();
//     timer = Timer.periodic(const Duration(milliseconds: 100), _tick);
//   }

//   void _tick(Timer t) {
//     if (!mounted) return;
//     setState(() {
//       progress += 1 / (widget.adDurationSeconds * 10);
//       remainingSeconds = ((1 - progress) * widget.adDurationSeconds).ceil();
//       if (!closeButtonVisible && progress >= widget.closeThreshold) {
//         closeButtonVisible = true;
//       }
//       if (progress >= 1.0) {
//         progress = 1.0;
//         timer.cancel();
//       }
//     });
//   }

//   void _handleClose() {
//     timer.cancel();
//     // Grant reward if watched enough
//     if (progress >= widget.closeThreshold && !rewardClaimed) {
//       rewardClaimed = true;
//       widget.onRewardEarned?.call(widget.rewardType, widget.rewardAmount);
//       widget.onAdClicked?.call();
//       _showRewardDialog();
//     } else {
//       Navigator.of(context).pop(false);
//       widget.onAdClosed?.call();
//     }
//   }

//   void _showRewardDialog() {
//     showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: const [
//             Icon(Icons.check_circle, color: Colors.green, size: 28),
//             SizedBox(width: 8),
//             Text('Reward Earned!'),
//           ],
//         ),
//         content: Text('You earned ${widget.rewardAmount} ${widget.rewardType}!'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close reward dialog
//               Navigator.of(context).pop(true); // Close ad
//               widget.onAdClosed?.call();
//             },
//             child: const Text('COLLECT', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     if (timer.isActive) timer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(children: [
//           // Video placeholder
//           Center(
//             child: Icon(Icons.smart_display, color: Colors.white54, size: 120),
//           ),
//           // Top bar
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Timer
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(children: [
//                     const Icon(Icons.timer, color: Colors.white70, size: 16),
//                     const SizedBox(width: 4),
//                     Text('$remainingSeconds s',
//                         style: const TextStyle(color: Colors.white, fontSize: 14)),
//                   ]),
//                 ),
//                 // Close button
//                 if (closeButtonVisible)
//                   Tooltip(
//                     message: widget.closeButtonTooltip,
//                     child: GestureDetector(
//                       onTap: _handleClose,
//                       child: Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                         ),
//                         child: const Icon(Icons.close, size: 20, color: Colors.black87),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           // Bottom controls
//           Positioned(
//             bottom: 24,
//             left: 24,
//             right: 24,
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               LinearProgressIndicator(
//                 value: progress,
//                 backgroundColor: Colors.white24,
//                 valueColor: AlwaysStoppedAnimation(Colors.greenAccent),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size.fromHeight(48),
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                 ),
//                 onPressed: progress >= 1.0 ? _handleClose : null,
//                 child: Text(progress >= 1.0
//                     ? widget.claimButtonText
//                     : widget.watchingInstruction),
//               ),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }
