import SwiftUI

struct Sidebar: View {
    
    @Environment(\.accessibilityAssistiveAccessEnabled) private var isAssistiveAccessEnabled

    @Bindable var cloudController: CloudController = .shared
    
    @Binding var selectedScreen: MainScreen?
    
    @State var showingCutter = false
    
    #if DEBUG
    @State var showingDebugImportSprites = false
    @State var showingDebugCreateHTML = false
    @State var showingDebugPromoGrid = false
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
                #if !os(visionOS)
                NavigationLink(value: MainScreen.collection(.stickersCollection)) {
                    Label {
                        Text("iMessage Stickers")
                    } icon: {
                        Image("Stickers Folder")
                            .sidebarIcon()
                    }
                }
                #endif
                NavigationLink(value: MainScreen.imports) {
                    Label {
                        Text("Imports")
                    } icon: {
                        Image("Imports Folder")
                            .sidebarIcon()
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
                    showingCutter = true
                } label: {
                    Label("Cut Sprites", systemImage: "scissors")
                }
            }
            #else
            if !isAssistiveAccessEnabled {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCutter = true
                    } label: {
                        Image(systemName: "scissors")
                    }
                    .buttonBorderShape(.circle)
                }
                
                ToolbarItemGroup(placement: .secondaryAction) {
                    #if DEBUG
                    Menu("Debug", systemImage: "ant") {
                        Button("Import Sprites", systemImage: "plus.square") {
                            showingDebugImportSprites = true
                        }
                        Button("Reorder", systemImage: "square.grid.2x2") {
                            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                let debugVC = DebugReorderViewController(collectionViewLayout: UICollectionViewFlowLayout())
                                let navVC = UINavigationController(rootViewController: debugVC)
                                navVC.modalPresentationStyle = .fullScreen
                                scene.windows.first?.rootViewController?.present(navVC, animated: true)
                            }
                        }
                        Button("Create HTML Pages", systemImage: "chevron.left.forwardslash.chevron.right") {
                            showingDebugCreateHTML = true
                        }
                        Button("Create Promo Grid", systemImage: "square.grid.3x3.square") {
                            showingDebugPromoGrid = true
                        }
                    }
                    #endif
                    
                    Section {
                        Link(destination: URL(string: "https://www.256arts.com/")!) {
                            Label("Developer Website", systemImage: "safari")
                        }
                        Link(destination: URL(string: "https://www.256arts.com/joincommunity/")!) {
                            Label("Join Community", systemImage: "bubble.left.and.bubble.right")
                        }
                        Link(destination: URL(string: "https://form.jotform.com/211994359527266")!) {
                            Label("Submit Your Sprites", systemImage: "paperplane")
                        }
                        Link(destination: URL(string: "https://github.com/256Arts/Sprite-Catalog")!) {
                            Label("Contribute on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        }
                    }
                }
            }
            #endif
        }
        .sheet(isPresented: $showingCutter) {
            NavigationStack {
                CutterView()
            }
        }
        #if DEBUG
        .sheet(isPresented: $showingDebugImportSprites) {
            ImportSpritesView(importer: .init(debugMode: true))
        }
        .sheet(isPresented: $showingDebugCreateHTML) {
            DebugCreateHTMLView()
        }
        .sheet(isPresented: $showingDebugPromoGrid) {
            DebugPromoGridView()
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
                Text(tag.rawValue)
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
            #if targetEnvironment(macCatalyst)
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
