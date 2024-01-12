//
//  HelpView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-04-05.
//

import SwiftUI
import StoreKit

enum AppID: Int {
    case spritePencil = 1437835952
}

struct HelpView: View {
    
    enum HelpScreen {
        case stickersHelp
    }
    
    #if !os(visionOS)
    let appStoreVC: SKStoreProductViewController = {
        let vc = SKStoreProductViewController()
        vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: AppID.spritePencil.rawValue]) { (result, error) in
            print(error?.localizedDescription as Any)
        }
        return vc
    }()
    #endif
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Send iMessage Stickers", value: HelpScreen.stickersHelp)
                }
                Section {
                    Link("Submit Your Sprites", destination: URL(string: "https://form.jotform.com/211994359527266")!)
                }
                Section {
                    #if !os(visionOS)
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            scene.windows.first?.rootViewController?.presentedViewController?.present(appStoreVC, animated: true)
                        }
                    } label: {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Try Sprite Pencil")
                                Text("Create Pixel Art")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "arrow.down.app")
                                .imageScale(.large)
                        }
                    }
                    .foregroundColor(Color.accentColor)
                    #endif
                    
                    Link(destination: URL(string: "https://www.256arts.com/")!) {
                        Label("Developer Website", systemImage: "safari")
                    }
                    Link(destination: URL(string: "https://www.256arts.com/joincommunity/")!) {
                        Label("Join Community", systemImage: "bubble.left.and.bubble.right")
                    }
                    Link(destination: URL(string: "https://github.com/256Arts/Sprite-Fonts")!) {
                        Label("Contribute on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }
            }
            .navigationTitle("Help")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: HelpScreen.self) { screen in
                StickersHelpView()
            }
        }
        .imageScale(.large)
    }
}

struct StickersHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "1.circle.fill")
                Text("Open a sprite you want to add to your sticker collection.")
            }
            HStack {
                Image(systemName: "2.circle.fill")
                Text("Tap \(Image(systemName: "plus.circle")).")
            }
            HStack {
                Image(systemName: "3.circle.fill")
                Text("Tap \"Stickers\" so it has a checkmark.")
            }
            HStack {
                Image(systemName: "4.circle.fill")
                Text("Open iMessage and you can now send your sticker.")
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Send iMessage Stickers")
    }
}

#Preview {
    HelpView()
}
