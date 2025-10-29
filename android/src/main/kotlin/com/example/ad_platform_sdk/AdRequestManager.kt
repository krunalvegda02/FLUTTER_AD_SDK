package com.example.ad_platform_sdk

class AdRequestManager {

    // Simple in-memory cache for loaded ads by their placement ID
    private val loadedInterstitialAds = mutableMapOf<String, Boolean>()
    private val loadedRewardedAds = mutableMapOf<String, Boolean>()

    // Mock loading interstitial ad
    fun loadInterstitialAd(placementId: String, callback: (success: Boolean) -> Unit) {
        // Simulate network/load delay
        Thread {
            Thread.sleep(1000)
            loadedInterstitialAds[placementId] = true
            callback(true)
        }.start()
    }

    // Mock loading rewarded ad
    fun loadRewardedAd(placementId: String, callback: (success: Boolean) -> Unit) {
        Thread {
            Thread.sleep(1000)
            loadedRewardedAds[placementId] = true
            callback(true)
        }.start()
    }

    fun isInterstitialAdLoaded(placementId: String): Boolean {
        return loadedInterstitialAds[placementId] ?: false
    }

    fun isRewardedAdLoaded(placementId: String): Boolean {
        return loadedRewardedAds[placementId] ?: false
    }
}
