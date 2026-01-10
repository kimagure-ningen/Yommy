import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let appGroupId = "group.com.example.yommy"
    private let sharedKey = "SharedURLs"
    private var flutterChannel: FlutterMethodChannel?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        flutterChannel = FlutterMethodChannel(
            name: "com.example.yommy/share",
            binaryMessenger: controller.binaryMessenger
        )
        
        flutterChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "getSharedURLs":
                result(self?.getSharedURLs() ?? [])
            case "getSharedUrl":
                let urls = self?.getSharedURLs() ?? []
                result(urls.first)
            case "clearSharedURLs":
                self?.clearSharedURLs()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Handle URL Scheme
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if url.scheme == "yommy" {
            // URL Scheme で開かれた場合、Flutter に通知
            // Flutter 側は resumed 時に getSharedURLs を呼ぶので、ここでは何もしなくてOK
            return true
        }
        return super.application(app, open: url, options: options)
    }
    
    private func getSharedURLs() -> [String] {
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else {
            return []
        }
        return userDefaults.stringArray(forKey: sharedKey) ?? []
    }
    
    private func clearSharedURLs() {
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else {
            return
        }
        userDefaults.removeObject(forKey: sharedKey)
        userDefaults.synchronize()
    }
}