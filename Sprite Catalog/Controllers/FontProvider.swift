import CoreText
import Foundation

/// Tracks which of the catalog's font families are installed system-wide, and installs them.
///
/// Installing a family means registering its files with `CTFontManager` in the persistent scope.
/// The platforms diverge in what gets registered and how that state is read back: iOS registers the
/// app bundle's own copies and can list what this process registered, while macOS cannot list
/// registrations at all — but it will report the scope of a file URL, so it registers copies kept in
/// Application Support and asks about those.
@Observable
final class FontProvider {
    
    static let shared = FontProvider()
    
    private(set) var registeredFamilies = Set<String>()
    
    init() {
        NotificationCenter.default.addObserver(forName: kCTFontManagerRegisteredFontsChangedNotification as Notification.Name, object: nil, queue: .main) { [weak self] _ in
            self?.updateRegisteredFonts()
        }
        updateRegisteredFonts()
    }
    
    /// Makes the family available to every app on the device.
    func install(_ family: FontFamily) {
        let urls = registrationURLs(for: family)
        #if os(macOS)
        do {
            try FileManager.default.createDirectory(at: Self.installedFontsDirectory, withIntermediateDirectories: true)
            for (font, destination) in zip(family.fonts, urls) where !FileManager.default.fileExists(atPath: destination.path(percentEncoded: false)) {
                try FileManager.default.copyItem(at: font.fileURL, to: destination)
            }
        } catch {
            return
        }
        #endif
        CTFontManagerRegisterFontURLs(urls as CFArray, .persistent, true) { [weak self] _, done in
            guard done else { return true }
            DispatchQueue.main.async {
                self?.updateRegisteredFonts()
            }
            return true
        }
    }
    
    func uninstall(_ family: FontFamily) {
        let urls = registrationURLs(for: family)
        CTFontManagerUnregisterFontURLs(urls as CFArray, .persistent) { [weak self] _, done in
            guard done else { return true }
            #if os(macOS)
            for url in urls {
                try? FileManager.default.removeItem(at: url)
            }
            #endif
            DispatchQueue.main.async {
                self?.updateRegisteredFonts()
            }
            return true
        }
    }
    
    private func updateRegisteredFonts() {
        #if os(macOS)
        registeredFamilies = Set(FontFamily.allFamilies.lazy.filter(isInstalled).map(\.name))
        #else
        let descriptors = CTFontManagerCopyRegisteredFontDescriptors(.persistent, true) as? [CTFontDescriptor] ?? []
        registeredFamilies = Set(descriptors.map { descriptor in
            CTFontCopyFamilyName(CTFontCreateWithFontDescriptor(descriptor, 0.0, nil)) as String
        })
        #endif
    }
    
    /// The files a persistent registration points at, which is not where the family is previewed
    /// from on macOS.
    private func registrationURLs(for family: FontFamily) -> [URL] {
        #if os(macOS)
        family.fonts.map(installedURL(for:))
        #else
        family.fonts.map(\.fileURL)
        #endif
    }
    
    #if os(macOS)
    /// Where installed copies live. A persistent registration points at a file rather than taking a
    /// copy of it, so registering the app bundle's own font would break the moment the app is moved,
    /// updated or deleted.
    private static let installedFontsDirectory = URL.applicationSupportDirectory.appending(path: "Installed Fonts", directoryHint: .isDirectory)
    
    private func installedURL(for font: FontFamily.Font) -> URL {
        Self.installedFontsDirectory.appending(path: font.fileURL.lastPathComponent, directoryHint: .notDirectory)
    }
    
    /// macOS has no equivalent of `CTFontManagerCopyRegisteredFontDescriptors`, but it will report
    /// the scope a file URL is registered in — and every file this app installs is one it copied.
    private func isInstalled(_ family: FontFamily) -> Bool {
        !family.fonts.isEmpty && family.fonts.allSatisfy {
            CTFontManagerGetScopeForURL(installedURL(for: $0) as CFURL) == .persistent
        }
    }
    #endif
    
}
