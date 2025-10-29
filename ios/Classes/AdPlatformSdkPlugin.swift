// ios/Classes/AdPlatformSdkPlugin.swift

import Flutter
import UIKit

public class AdPlatformSdkPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel!
  private var adRequestManager = AdRequestManager()
  private var adViewController: AdViewController!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AdPlatformSdkPlugin()
    instance.adViewController = AdViewController(registrar.messenger(), rootViewController: UIApplication.shared.keyWindow?.rootViewController)
    instance.channel = FlutterMethodChannel(name: "com.yourplatform.adsdk/methods", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: instance.channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "loadInterstitial":
        guard let args = call.arguments as? [String: Any], let adId = args["adId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Ad ID required", details: nil))
          return
        }
        adRequestManager.loadInterstitialAd(placementId: adId) { success in
          result(success)
        }
      case "showInterstitial":
        guard let args = call.arguments as? [String: Any], let adId = args["adId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Ad ID required", details: nil))
          return
        }
        if adRequestManager.isInterstitialAdLoaded(placementId: adId) {
          let shown = adViewController.showInterstitialAd(placementId: adId) {
            self.channel.invokeMethod("onAdClicked", arguments: nil)
          } onClosed: {
            self.channel.invokeMethod("onAdClosed", arguments: nil)
          }
          result(shown)
        } else {
          result(FlutterError(code: "NOT_LOADED", message: "Interstitial not loaded", details: nil))
        }
      case "loadRewarded":
        guard let args = call.arguments as? [String: Any], let adId = args["adId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Ad ID required", details: nil))
          return
        }
        adRequestManager.loadRewardedAd(placementId: adId) { success in
          result(success)
        }
      case "showRewarded":
        guard let args = call.arguments as? [String: Any], let adId = args["adId"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Ad ID required", details: nil))
          return
        }
        if adRequestManager.isRewardedAdLoaded(placementId: adId) {
          let shown = adViewController.showRewardedAd(placementId: adId,
            onReward: { type, amount in
              self.channel.invokeMethod("onRewardEarned", arguments: ["type": type, "amount": amount])
            },
            onClicked: {
              self.channel.invokeMethod("onAdClicked", arguments: nil)
            },
            onClosed: {
              self.channel.invokeMethod("onAdClosed", arguments: nil)
            }
          )
          result(shown)
        } else {
          result(FlutterError(code: "NOT_LOADED", message: "Rewarded not loaded", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
    }
  }
}
