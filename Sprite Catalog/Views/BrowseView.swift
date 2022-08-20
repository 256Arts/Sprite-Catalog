//
//  BrowseView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-06-16.
//

import StoreKit
import SwiftUI

struct BrowseView: View {
    
    let appStoreVC: SKStoreProductViewController = {
        let vc = SKStoreProductViewController()
        vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: AppID.spritePencil.rawValue]) { (result, error) in
            print(error?.localizedDescription as Any)
        }
        return vc
    }()
    
    let featuredArtists = [
        Artist(name: "SciGho"),
        Artist(name: "Gif"),
        Artist(name: "Henry Software"),
        Artist(name: "devurandom"),
        Artist(name: "Josehzz")
    ]
    
    var suggestions: [SpriteSet] {
        guard let ids = UserDefaults.standard.stringArray(forKey: UserDefaults.Key.suggestions) else { return [] }
        return SpriteSet.allSprites.filter({ ids.contains($0.id) })
    }
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Group {
                    HStack {
                        Text("Gaming")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SpriteCollection.gaming) { collection in
                                NavigationLink(
                                    destination: CollectionView(collection: collection, webpageURL: nil),
                                    label: {
                                        BrowseCollectionView(collection: collection, isLarge: false)
                                    })
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Featured")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SpriteCollection.featured) { collection in
                                NavigationLink(
                                    destination: CollectionView(collection: collection, webpageURL: nil),
                                    label: {
                                        BrowseCollectionView(collection: collection, isLarge: true)
                                    })
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        Text("Artists")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(featuredArtists) { artist in
                                NavigationLink(
                                    destination: CollectionView(collection: SpriteCollection(artist: artist), webpageURL: artist.url),
                                    label: {
                                        BrowseCollectionView(collection: SpriteCollection(artist: artist), isLarge: false)
                                    })
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.blue, .init(red: 0.0, green: 1.0, blue: 0.45)]), startPoint: .leading, endPoint: .bottomTrailing)
                    if hSizeClass == .compact {
                        VStack {
                            Text("Sprite Pencil")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("Create Pixel Art")
                                .font(.title)
                                .foregroundColor(.secondary)
                            Image("SP iPad")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .padding()
                    } else {
                        HStack {
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Sprite Pencil")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Create Pixel Art")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                            }
                            .fixedSize()
                            Spacer()
                            Image("SP iPad")
                            Spacer()
                        }
                        .padding(24)
                    }
                }
                .onTapGesture {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        scene.windows.first?.rootViewController?.present(appStoreVC, animated: true)
                    }
                }
                .padding(.top)
                
                if 3 < suggestions.count {
                    HStack {
                        Text("Based on Your Recent Activity")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(suggestions) { sprite in
                                NavigationLink(destination: SpriteDetailView(sprite: sprite)) {
                                    TileThumbnail(tile: sprite.tiles[0])
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                    .frame(height: 20)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Browse")
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView()
    }
}
