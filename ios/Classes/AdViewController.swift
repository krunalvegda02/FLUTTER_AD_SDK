// ios/Classes/AdViewController.swift

import UIKit

public class AdViewController {
  private let rootViewController: UIViewController?

  public init(_ messenger: FlutterBinaryMessenger, rootViewController: UIViewController?) {
    self.rootViewController = rootViewController
  }

  @discardableResult
  public func showInterstitialAd(
    placementId: String,
    onClicked: @escaping () -> Void,
    onClosed: @escaping () -> Void
  ) -> Bool {
    guard let vc = rootViewController else { return false }
    let alert = UIAlertController(title: "Interstitial Ad", message: "Showing ad: \(placementId)", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Click", style: .default) { _ in
      onClicked()
      onClosed()
    })
    alert.addAction(UIAlertAction(title: "Close", style: .cancel) { _ in
      onClosed()
    })
    vc.present(alert, animated: true, completion: nil)
    return true
  }

  @discardableResult
  public func showRewardedAd(
    placementId: String,
    onReward: @escaping (String, Int) -> Void,
    onClicked: @escaping () -> Void,
    onClosed: @escaping () -> Void
  ) -> Bool {
    guard let vc = rootViewController else { return false }
    let alert = UIAlertController(title: "Rewarded Ad", message: "Watch to earn reward", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Claim", style: .default) { _ in
      onClicked()
      onReward("coins", 50)
      onClosed()
    })
    alert.addAction(UIAlertAction(title: "Close", style: .cancel) { _ in
      onClosed()
    })
    vc.present(alert, animated: true, completion: nil)
    return true
  }
}
