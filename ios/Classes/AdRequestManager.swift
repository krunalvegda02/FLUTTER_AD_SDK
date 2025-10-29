// ios/Classes/AdRequestManager.swift

import Foundation

public class AdRequestManager {
  private var loadedInterstitialAds = [String: Bool]()
  private var loadedRewardedAds = [String: Bool]()

  public func loadInterstitialAd(placementId: String, callback: @escaping (Bool) -> Void) {
    // Simulate network delay
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
      self.loadedInterstitialAds[placementId] = true
      callback(true)
    }
  }

  public func loadRewardedAd(placementId: String, callback: @escaping (Bool) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
      self.loadedRewardedAds[placementId] = true
      callback(true)
    }
  }

  public func isInterstitialAdLoaded(placementId: String) -> Bool {
    return loadedInterstitialAds[placementId] ?? false
  }

  public func isRewardedAdLoaded(placementId: String) -> Bool {
    return loadedRewardedAds[placementId] ?? false
  }
}
