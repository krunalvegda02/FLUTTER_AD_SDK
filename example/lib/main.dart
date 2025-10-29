// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:ad_platform_sdk/ad_platform_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ad Platform SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Ad Platform SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _sdkInitialized = false;
  String _initializationStatus = 'Initializing SDK...';

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  Future<void> _initializeSDK() async {
    try {
      final success = await AdPlatformSDK.instance.initialize(
        publisherId: 'pub_demo_123456',
        apiKey: 'your_api_key_here',
        environment: 'development',
        enableLogging: true,
      );

      setState(() {
        _sdkInitialized = success;
        _initializationStatus = success 
          ? 'SDK initialized successfully!' 
          : 'SDK initialization failed';
      });
    } catch (e) {
      setState(() {
        _sdkInitialized = false;
        _initializationStatus = 'SDK initialization error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _sdkInitialized ? Colors.green.shade100 : Colors.red.shade100,
            child: Text(
              _initializationStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _sdkInitialized ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Banner Ads:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Medium Rectangle Banner
                  if (_sdkInitialized)
                    BannerAdWidget(
                      placementId: 'banner_demo_1',
                      size: AdSize.banner300x250,
                      targeting: const {
                        'category': 'technology',
                        'keywords': ['flutter', 'mobile', 'sdk'],
                      },
                      onAdLoaded: (adId) {
                        print('Banner ad loaded: $adId');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Banner ad loaded: $adId')),
                        );
                      },
                      onAdFailed: (error) {
                        print('Banner ad failed: $error');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Banner ad failed: $error')),
                        );
                      },
                      onAdClicked: (adId) {
                        print('Banner ad clicked: $adId');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Banner ad clicked: $adId')),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Mobile Banner:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mobile Banner
                  if (_sdkInitialized)
                    BannerAdWidget(
                      placementId: 'mobile_banner_1',
                      size: AdSize.banner320x50,
                      targeting: const {
                        'category': 'mobile_apps',
                      },
                      onAdLoaded: (adId) {
                        print('Mobile banner loaded: $adId');
                      },
                      onAdFailed: (error) {
                        print('Mobile banner failed: $error');
                      },
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Interstitial Ad Button
                  const Text(
                    'Interstitial Ad:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: _sdkInitialized ? _loadAndShowInterstitial : null,
                    child: const Text('Load & Show Interstitial Ad'),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Rewarded Ad Button
                  const Text(
                    'Rewarded Ad:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: _sdkInitialized ? _loadRewardedAd : null,
                    child: const Text('Load Rewarded Ad'),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // SDK Info
                  if (_sdkInitialized)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SDK Information:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Version: ${AdPlatformSDK.instance.version}'),
                            Text('Publisher ID: ${AdPlatformSDK.instance.config?.publisherId}'),
                            Text('Environment: ${AdPlatformSDK.instance.config?.environment}'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAndShowInterstitial() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading interstitial ad...')),
      );

      final adRequest = AdRequest(
        placementId: 'interstitial_demo_1',
        size: AdSize.interstitial320x480,
        adFormat: AdFormat.interstitial,
        targeting: const {
          'category': 'games',
          'age_group': '18-35',
        },
      );

      final response = await AdPlatformSDK.instance.loadInterstitialAd(adRequest);
      
      if (response != null && response.success && response.ad != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Showing interstitial ad...')),
        );
        
        final shown = await AdPlatformSDK.instance.showInterstitialAd(response.ad!.id);
        
        if (!shown) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to show interstitial ad')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load interstitial ad')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _loadRewardedAd() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading rewarded ad...')),
      );

      final adRequest = AdRequest(
        placementId: 'rewarded_demo_1',
        size: AdSize.rewardedVideo,
        adFormat: AdFormat.rewarded,
        targeting: const {
          'category': 'entertainment',
          'reward_type': 'coins',
        },
      );

      final response = await AdPlatformSDK.instance.loadRewardedAd(adRequest);
      
      if (response != null && response.success && response.ad != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rewarded ad loaded: ${response.ad!.id}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load rewarded ad')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    // SDK will auto-dispose when app closes
    super.dispose();
  }
}
