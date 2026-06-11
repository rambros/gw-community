import Flutter
import UIKit
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // super must run first so the Flutter engine + messenger are ready before
    // GeneratedPluginRegistrant calls each plugin's register(with:).
    // app_links v6.4.1 checks messenger != nil in DEBUG mode and bails out
    // early if it is nil (which it will be if register is called before super).
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    GeneratedPluginRegistrant.register(with: self)

    // Propagate cold-start custom-scheme URL to app_links.
    // iOS delivers this via launchOptions, not via application:open:url:options:.
    if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
      AppLinks.shared.handleLink(url: url)
    }

    return result
  }

  // Warm-start custom URL scheme delivery (app already running).
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options)
  }

  // Universal Links delivery.
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
