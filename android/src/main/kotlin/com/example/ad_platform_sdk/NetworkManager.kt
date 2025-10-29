package com.example.ad_platform_sdk

import android.util.Log

class NetworkManager {

    fun fetchAdConfig(placementId: String, callback: (configJson: String?) -> Unit) {
        // Mock: return dummy JSON config, or call your real server async
        Thread {
            Thread.sleep(500)
            val dummyJson = """
                {
                  "placementId": "$placementId",
                  "adType": "interstitial",
                  "creativeUrl": "https://example.com/ad.jpg"
                }
            """.trimIndent()
            Log.d("NetworkManager", "Fetched config for $placementId")
            callback(dummyJson)
        }.start()
    }
}
