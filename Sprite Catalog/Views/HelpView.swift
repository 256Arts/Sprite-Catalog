//
//  HelpView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-04-05.
//

import SwiftUI
import StoreKit

enum AppID: Int {
    case spritePencil = 1437835952
    case spriteFonts = 1554027877
}

struct HelpView: View {
    
    let appStoreVC: SKStoreProductViewController = {
        let vc = SKStoreProductViewController()
        vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: AppID.spritePencil.rawValue]) { (result, error) in
            print(error?.localizedDescription as Any)
        }
        return vc
    }()
    let appStoreVC2: SKStoreProductViewController = {
        let vc = SKStoreProductViewController()
        vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: AppID.spriteFonts.rawValue]) { (result, error) in
            print(error?.localizedDescription as Any)
        }
        return vc
    }()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink("Send iMessage Stickers", destination: StickersHelpView())
                }
                Section {
                    Link("Submit Your Sprites", destination: URL(string: "https://form.jotform.com/211994359527266")!)
                }
                Section {
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
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        } icon: {
                            Image(systemName: "arrow.down.app")
                                .imageScale(.large)
                        }
                    }
                    .foregroundColor(Color.accentColor)
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            scene.windows.first?.rootViewController?.presentedViewController?.present(appStoreVC2, animated: true)
                        }
                    } label: {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Try Sprite Fonts")
                                Text("Install Pixel Fonts")
                                    .font(.subheadline)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                            }
                        } icon: {
                            Image(systemName: "arrow.down.app")
                                .imageScale(.large)
                        }
                    }
                    .foregroundColor(Color.accentColor)
                    Link("Developer Website", destination: URL(string: "https://www.jaydenirwin.com/")!)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Help")
            .toolbar(content: {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            })
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

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
