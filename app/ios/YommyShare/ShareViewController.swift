import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {
    
    private let appGroupId = "group.com.example.yommy"
    private let sharedKey = "SharedURLs"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleSharedContent()
    }
    
    private func handleSharedContent() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completeRequest()
            return
        }
        
        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            
            for attachment in attachments {
                // Handle URLs
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { [weak self] (data, error) in
                        if let url = data as? URL {
                            self?.saveURLAndOpenApp(url.absoluteString)
                        } else {
                            self?.completeRequest()
                        }
                    }
                    return
                }
                
                // Handle plain text (might contain URL)
                if attachment.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil) { [weak self] (data, error) in
                        if let text = data as? String {
                            // Check if it's a URL
                            if let url = URL(string: text), url.scheme != nil {
                                self?.saveURLAndOpenApp(text)
                            } else if let detected = self?.detectURL(in: text) {
                                self?.saveURLAndOpenApp(detected)
                            } else {
                                self?.completeRequest()
                            }
                        } else {
                            self?.completeRequest()
                        }
                    }
                    return
                }
            }
        }
        
        completeRequest()
    }
    
    private func detectURL(in text: String) -> String? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let match = matches?.first, let range = Range(match.range, in: text) {
            return String(text[range])
        }
        return nil
    }
    
    private func saveURLAndOpenApp(_ urlString: String) {
        // Save URL to App Groups
        saveURL(urlString)
        
        // Open main app with URL scheme
        openMainApp()
        
        // Complete the share extension
        completeRequest()
    }
    
    private func saveURL(_ urlString: String) {
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else { return }
        
        var urls = userDefaults.stringArray(forKey: sharedKey) ?? []
        
        // Avoid duplicates
        if !urls.contains(urlString) {
            urls.append(urlString)
            userDefaults.set(urls, forKey: sharedKey)
            userDefaults.synchronize()
        }
    }
    
    private func openMainApp() {
        let urlString = "yommy://share"
        guard let url = URL(string: urlString) else { return }
        
        // Use responder chain to open URL
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                return
            }
            responder = responder?.next
        }
        
        // Alternative method using selector
        let selector = sel_registerName("openURL:")
        responder = self
        while responder != nil {
            if responder!.responds(to: selector) {
                responder!.perform(selector, with: url)
                return
            }
            responder = responder?.next
        }
    }
    
    private func completeRequest() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}