// ios/Classes/NetworkManager.swift

import Foundation

public class NetworkManager {
  public func fetchAdConfig(placementId: String, callback: @escaping (String?) -> Void) {
    // Simulate fetching JSON config
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
      let dummyJson = """
      {
        "placementId": "\(placementId)",
        "adType": "interstitial",
        "creativeUrl": "https://example.com/ad.jpg"
      }
      """
      callback(dummyJson)
    }
  }
}
