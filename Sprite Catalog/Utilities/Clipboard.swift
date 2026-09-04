#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// The system clipboard. UIKit and AppKit spell a button-driven copy differently and SwiftUI's
/// `copyable` needs focus, so the one place that copies text goes through here.
enum Clipboard {

    static func copy(_ string: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = string
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #endif
    }

}
