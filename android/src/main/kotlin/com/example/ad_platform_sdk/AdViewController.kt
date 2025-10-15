package com.example.ad_platform_sdk

import android.app.Activity
import android.content.Context
import android.widget.Toast

class AdViewController(private val context: Context) {

    // Show interstitial ad mock
    fun showInterstitialAd(
        placementId: String,
        onAdClicked: (() -> Unit)? = null,
        onAdClosed: (() -> Unit)? = null
    ): Boolean {
        // For mock, just toast then callback
        Toast.makeText(context, "Showing Interstitial Ad: $placementId", Toast.LENGTH_SHORT).show()
        onAdClicked?.invoke()
        onAdClosed?.invoke()
        return true
    }

    // Show rewarded ad mock
    fun showRewardedAd(
        placementId: String,
        onAdRewardEarned: ((type: String, amount: Int) -> Unit)? = null,
        onAdClicked: (() -> Unit)? = null,
        onAdClosed: (() -> Unit)? = null
    ): Boolean {
        Toast.makeText(context, "Showing Rewarded Ad: $placementId", Toast.LENGTH_SHORT).show()
        onAdClicked?.invoke()
        // Simulate user earning reward
        onAdRewardEarned?.invoke("coins", 50)
        onAdClosed?.invoke()
        return true
    }
}
