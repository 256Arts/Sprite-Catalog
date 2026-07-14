import UIKit
#if canImport(NotificationCenter)
import NotificationCenter
#endif

@Observable
final class FontProvider {
    
    static let shared = FontProvider()
    
    var registeredFamilies = Set<String>()
    
    init() {
        #if canImport(NotificationCenter)
        NotificationCenter.default.addObserver(self, selector: #selector(updateRegisteredFonts), name: kCTFontManagerRegisteredFontsChangedNotification as Notification.Name, object: nil)
        #endif
    }
    
    @objc func updateRegisteredFonts(_ sender: Any) {
        registeredFamilies.removeAll()
        guard let registeredDescriptors = CTFontManagerCopyRegisteredFontDescriptors(.persistent, true) as? [CTFontDescriptor] else { return }
        for descriptor in registeredDescriptors {
            if let postname = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String {
                if let font = UIFont(name: postname, size: 12.0) {
                    registeredFamilies.insert(font.familyName)
                }
            }
        }
    }
    
}
