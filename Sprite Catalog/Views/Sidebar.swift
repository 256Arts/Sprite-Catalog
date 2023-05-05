//
//  Sidebar.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-03-26.
//

import SwiftUI
import WelcomeKit

struct Sidebar: View {
    
    let welcomeFeatures = [
        WelcomeFeature(image: Image(systemName: "square.grid.2x2.fill"), title: "2000+ Sprites", body: "Including exclusive sprites."),
        WelcomeFeature(image: Image(systemName: "paintbrush.fill"), title: "Quick Recolor", body: "Recolor any sprite."),
        WelcomeFeature(image: Image("Sprite Pencil"), title: "One-Tap Edit", body: "Open in Sprite Pencil in one tap.")
    ]
    
    @AppStorage(UserDefaults.Key.whatsNewVersion) var whatsNewVersion = 0

    @ObservedObject var cloudController: CloudController = .shared
    
    @Binding var selectedScreen: MainScreen?
    
    @State var showingWelcome = false
    @State var showingHelp = false
    
    #if DEBUG
    @State var showingDebugImportSprites = false
    @State var showingDebugCreateHTML = false
    @State var showingDebugPromoGrid = false
    #endif
    
    var body: some View {
        List(selection: $selectedScreen) {
            NavigationLink(value: MainScreen.browse) {
                Label(title: {
                    Text("Browse")
                }) {
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
                CategoryLink(tag: .object, iconName: "ohdawf")
                CategoryLink(tag: .effect, iconName: "60by9c")
                CategoryLink(tag: .interface, iconName: "c3pj4c")
                CategoryLink(tag: .tile, iconName: "eg4s6n")
                CategoryLink(tag: .artwork, iconName: "zfqsjq")
            }
            Section(header: Text("Library")) {
                NavigationLink(value: MainScreen.collection(.myCollection)) {
                    Label(title: {
                        Text("My Collection")
                    }) {
                        Image("6j6ljq")
                            .sidebarIcon()
                    }
                }
                NavigationLink(value: MainScreen.collection(.stickersCollection)) {
                    Label(title: {
                        Text("Stickers")
                    }) {
                        Image("6j6ljq")
                            .sidebarIcon()
                    }
                }
                NavigationLink {
                    if let collection = cloudController.spriteCollection {
                        ImportedCollectionSpritesGridView(userCollection: collection)
                    } else {
                        ProgressView()
                    }
                } label: {
                    Label(title: {
                        Text("Imported")
                    }) {
                        Image("6j6ljq")
                            .sidebarIcon()
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Sprite Catalog")
        .navigationBarTitleDisplayMode(.inline)
        #if targetEnvironment(macCatalyst)
        .navigationBarHidden(true)
        #endif
        .toolbar {
            #if DEBUG
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingDebugImportSprites = true
                    } label: {
                        Label("Import Sprites", systemImage: "plus.square")
                    }
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            let debugVC = DebugReorderViewController(collectionViewLayout: UICollectionViewFlowLayout())
                            let navVC = UINavigationController(rootViewController: debugVC)
                            navVC.modalPresentationStyle = .fullScreen
                            scene.windows.first?.rootViewController?.present(navVC, animated: true)
                        }
                    } label: {
                        Label("Reorder", systemImage: "square.grid.2x2")
                    }
                    Button {
                        showingDebugCreateHTML = true
                    } label: {
                        Label("Create HTML Pages", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    Button {
                        showingDebugPromoGrid = true
                    } label: {
                        Label("Create Promo Grid", systemImage: "square.grid.3x3.square")
                    }
                } label: {
                    Image(systemName: "ant")
                }
            }
            #endif
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingHelp = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .onAppear {
            if whatsNewVersion < Sprite_CatalogApp.appWhatsNewVersion {
                showingWelcome = true
            }
        }
        .sheet(isPresented: $showingWelcome, onDismiss: {
            if whatsNewVersion < Sprite_CatalogApp.appWhatsNewVersion {
                whatsNewVersion = Sprite_CatalogApp.appWhatsNewVersion
            }
        }, content: {
            WelcomeView(isFirstLaunch: whatsNewVersion == 0, appName: "Sprite Catalog", features: welcomeFeatures)
        })
        .sheet(isPresented: $showingHelp, content: {
            HelpView()
        })
        #if DEBUG
        .sheet(isPresented: $showingDebugImportSprites, content: {
            ImportSpritesView(importer: .init(debugMode: true))
        })
        .sheet(isPresented: $showingDebugCreateHTML, content: {
            DebugCreateHTMLView()
        })
        .sheet(isPresented: $showingDebugPromoGrid, content: {
            DebugPromoGridView()
        })
        #endif
    }
}

struct CategoryLink: View {
    
    @State var tag: SpriteSet.Tag
    @State var iconName: String
    
    var body: some View {
        NavigationLink(value: MainScreen.category(tag)) {
            Label(title: {
                Text(tag.rawValue)
            }) {
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

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(selectedScreen: .constant(.browse))
    }
}
