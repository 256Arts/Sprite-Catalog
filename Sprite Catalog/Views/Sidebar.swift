import SwiftUI

struct Sidebar: View {
    
    @Environment(\.accessibilityAssistiveAccessEnabled) private var isAssistiveAccessEnabled
    /// The window's sheets, so a toolbar button here and the matching menu bar item flip the same
    /// flag. Optional because a preview has no window around it.
    @Environment(MainWindowState.self) private var window: MainWindowState?

    @Bindable var cloudController: CloudController = .shared
    
    @Binding var selectedScreen: MainScreen?
    
    #if DEBUG
    @State var showingDebugImportSprites = false
    @State var showingDebugPromoGrid = false
    @State var showingDebugReorder = false
    
    private var debugMenu: some View {
        Menu("Debug", systemImage: "ant") {
            Button("Import Sprites", systemImage: "plus.square") {
                showingDebugImportSprites = true
            }
            if #available(iOS 27, macOS 27, visionOS 27, *) {
                Button("Reorder", systemImage: "square.grid.2x2") {
                    showingDebugReorder = true
                }
            }
            Button("Create Promo Grid", systemImage: "square.grid.3x3.square") {
                showingDebugPromoGrid = true
            }
        }
    }
    #endif
    
    var body: some View {
        List(selection: $selectedScreen) {
            Section {
                NavigationLink(value: MainScreen.browse) {
                    Label {
                        Text("Browse")
                    } icon: {
                        Image("lzpsnc")
                            .sidebarIcon()
                    }
                }
                Group {
                    CategoryLink(tag: .peopleAnimal, iconName: "ybcclv")
                    CategoryLink(tag: .food, iconName: "vu654q")
                    CategoryLink(tag: .weaponTool, iconName: "46sbsg")
                    CategoryLink(tag: .clothing, iconName: "zbkmsq")
                    CategoryLink(tag: .treasure, iconName: "gzkavm")
                    CategoryLink(tag: .miscItem, iconName: "jf4lyr")
                }
                Group {
                    CategoryLink(tag: .nature, iconName: "y4oe7l")
                    CategoryLink(tag: .object, iconName: "vwtecl")
                    CategoryLink(tag: .effect, iconName: "60by9c")
                    CategoryLink(tag: .interface, iconName: "c3pj4c")
                    CategoryLink(tag: .tile, iconName: "eg4s6n")
                    CategoryLink(tag: .artwork, iconName: "zfqsjq")
                }
                NavigationLink(value: MainScreen.fonts) {
                    Label {
                        Text("Fonts")
                    } icon: {
                        Image("Fonts")
                            .sidebarIcon()
                    }
                }
                NavigationLink(value: MainScreen.palettes) {
                    Label {
                        Text("Palettes")
                    } icon: {
                        Image("ax4huo") // Paint Palette
                            .sidebarIcon()
                    }
                }
            }
            
            Section("Library") {
                NavigationLink(value: MainScreen.collection(.myCollection)) {
                    Label {
                        Text("My Collection")
                    } icon: {
                        Image("6j6ljq")
                            .sidebarIcon()
                    }
                }
                NavigationLink(value: MainScreen.myPalettes) {
                    Label {
                        Text("My Palettes")
                    } icon: {
                        Image("hpjwkm") // Paint Brush
                            .sidebarIcon()
                    }
                }
                if SpriteCollection.stickersAreAvailable {
                    NavigationLink(value: MainScreen.collection(.stickersCollection)) {
                        Label {
                            Text("iMessage Stickers")
                        } icon: {
                            Image("Stickers Folder")
                                .sidebarIcon()
                        }
                    }
                }
                NavigationLink(value: MainScreen.imports) {
                    Label {
                        Text("Imports")
                    } icon: {
                        Image("Imports Folder")
                            .sidebarIcon()
                    }
                }
                .contextMenu {
                    Button("Import Sprites…", systemImage: "plus") {
                        window?.showingImport = true
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Sprite Catalog")
        .toolbar {
            #if os(visionOS)
            ToolbarItem(placement: .primaryAction) {
                Button {
                    window?.showingCutter = true
                } label: {
                    Label("Cut Sprites", systemImage: "scissors")
                }
            }
            #else
            if !isAssistiveAccessEnabled {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        window?.showingCutter = true
                    } label: {
                        Label("Cut Sprites", systemImage: "scissors")
                            .labelStyle(.iconOnly)
                    }
                    .buttonBorderShape(.circle)
                }
                
                #if os(macOS)
                // Desktop lists the app's links in the menu bar's Help menu, where a Mac user looks
                // for them, so the overflow carries only the developer tools — and in a release
                // build, nothing at all.
                #if DEBUG
                ToolbarItemGroup(placement: .secondaryAction) {
                    debugMenu
                }
                #endif
                #else
                ToolbarItemGroup(placement: .secondaryAction) {
                    #if DEBUG
                    debugMenu
                    #endif
                    
                    Section {
                        HelpLinks()
                    }
                }
                #endif
            }
            #endif
        }
        #if DEBUG
        .sheet(isPresented: $showingDebugImportSprites) {
            ImportSpritesView(importer: .init(debugMode: true))
        }
        .sheet(isPresented: $showingDebugPromoGrid) {
            DebugPromoGridView()
        }
        .sheet(isPresented: $showingDebugReorder) {
            if #available(iOS 27, macOS 27, visionOS 27, *) {
                DebugReorderView()
            }
        }
        #endif
    }
}

struct CategoryLink: View {
    
    @State var tag: SpriteSet.Tag
    @State var iconName: String
    
    var body: some View {
        NavigationLink(value: MainScreen.category(tag)) {
            Label {
                Text(tag.title)
            } icon: {
                Image(iconName)
                    .sidebarIcon()
            }
        }
    }
    
}

extension Image {
    func sidebarIcon() -> some View {
        var sidebarIconSize: CGSize {
            #if os(macOS)
            CGSize(width: 24, height: 24)
            #else
            CGSize(width: 32, height: 32)
            #endif
        }
        
        return self
            .resizable()
            .interpolation(.none)
            .frame(width: sidebarIconSize.width, height: sidebarIconSize.height)
    }
}

#Preview {
    Sidebar(selectedScreen: .constant(.browse))
}
