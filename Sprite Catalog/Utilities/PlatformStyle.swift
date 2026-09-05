import SwiftUI

extension View {
    
    /// Styles a grid cell's tap target.
    ///
    /// iPhone and iPad let a `NavigationLink` draw its own button chrome; every other platform the
    /// app ships on draws hover or focus effects instead, so the link stays plain there.
    func cellButtonStyle() -> some View {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        self
        #else
        self
            .buttonBorderShape(.roundedRectangle)
            .buttonStyle(.plain)
        #endif
    }
    
    /// Leaves a menu open after the item is used, so several filters can be flipped in one go.
    /// macOS menu items with controls already behave that way.
    @ViewBuilder
    func keepsMenuOpen() -> some View {
        #if os(macOS)
        self
        #else
        menuActionDismissBehavior(.disabled)
        #endif
    }
    
    /// States how prominent a screen's title should be.
    ///
    /// `navigationBarTitleDisplayMode` is unavailable on macOS, where a window's title is always
    /// inline, so screens say what they want and the Mac quietly ignores it.
    @ViewBuilder
    func navigationTitleDisplayMode(_ mode: NavigationTitleDisplayMode) -> some View {
        #if os(macOS)
        self
        #else
        navigationBarTitleDisplayMode(mode == .inline ? .inline : .large)
        #endif
    }
    
}

enum NavigationTitleDisplayMode {
    case inline, large
}

extension ToolbarItemPlacement {
    
    /// The trailing end of a phone or tablet's navigation bar, and a Mac window's toolbar.
    static var barTrailing: ToolbarItemPlacement {
        #if os(macOS)
        .primaryAction
        #else
        .topBarTrailing
        #endif
    }
    
}

/// The system background colors the catalog's screens are built on. UIKit and AppKit name different
/// ones and SwiftUI has no cross-platform spelling, so every screen asks here.
extension Color {
    
    /// Behind a grid of cells.
    static var groupedBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
    
    /// A cell's own fill, one step in front of ``groupedBackground``.
    static var groupedCellBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }
    
    /// A section set apart from the plain content it follows, such as a detail screen's footer.
    static var secondaryBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
        #else
        Color(nsColor: .underPageBackgroundColor)
        #endif
    }
    
}
