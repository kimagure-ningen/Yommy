import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

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
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (data, error) in
                        if let url = data as? URL {
                            self?.saveURL(url.absoluteString)
                        }
                        self?.completeRequest()
                    }
                    return
                }
                
                // Handle plain text (might contain URL)
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (data, error) in
                        if let text = data as? String {
                            // Check if it's a URL
                            if let url = URL(string: text), url.scheme != nil {
                                self?.saveURL(text)
                            } else if let detected = self?.detectURL(in: text) {
                                self?.saveURL(detected)
                            }
                        }
                        self?.completeRequest()
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
    
    private func completeRequest() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
