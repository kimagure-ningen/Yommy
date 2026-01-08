import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let appGroupId = "group.com.example.yommy"
    private let sharedKey = "SharedURLs"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.example.yommy/share",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "getSharedURLs":
                result(self?.getSharedURLs() ?? [])
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