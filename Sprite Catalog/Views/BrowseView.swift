import SwiftUI

struct BrowseView: View {
    
    static let featuredArtists: [Artist] = {
        let allArtists = SpriteSet.allSprites.map({ $0.artist }).filter { $0.name != "Anonymous" }
        // Count number of occurrances of each artist
        let counts = allArtists.reduce(into: [:]) { counts, artist in counts[artist, default: 0] += 1 }
        // Only return artists with 20+ sprites
        let validArtists = counts.filter { 20 <= $0.value }.map { $0.key }
        // Pick 6 randomly
        return Array(validArtists.shuffled().prefix(6))
    }()
    
    var suggestions: [SpriteSet] {
        guard let ids = UserDefaults.standard.stringArray(forKey: UserDefaults.Key.suggestions) else { return [] }
        return SpriteSet.allSprites.filter({ ids.contains($0.id) })
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Group {
                    HStack {
                        Text("Gaming")
                            .font(.headline)
                        Spacer()
                    }
                    .safeAreaPadding(.horizontal, 20)
                    .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SpriteCollection.gaming) { collection in
                                NavigationLink(value: collection) {
                                    BrowseCollectionPreview(collection: collection, isLarge: false)
                                }
                                #if os(visionOS) || targetEnvironment(macCatalyst)
                                .buttonBorderShape(.roundedRectangle)
                                .buttonStyle(.plain)
                                #endif
                            }
                            Spacer()
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 20)
                    
                    HStack {
                        Text("Featured")
                            .font(.headline)
                        Spacer()
                    }
                    .safeAreaPadding(.horizontal, 20)
                    .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SpriteCollection.featured) { collection in
                                NavigationLink(value: collection) {
                                    BrowseCollectionPreview(collection: collection, isLarge: true)
                                }
                                #if os(visionOS) || targetEnvironment(macCatalyst)
                                .buttonBorderShape(.roundedRectangle)
                                .buttonStyle(.plain)
                                #endif
                            }
                            Spacer()
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 20)
                    
                    HStack {
                        Text("Artists")
                            .font(.headline)
                        Spacer()
                    }
                    .safeAreaPadding(.horizontal, 20)
                    .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Self.featuredArtists) { artist in
                                NavigationLink(value: artist) {
                                    BrowseCollectionPreview(collection: SpriteCollection(artist: artist), isLarge: false)
                                }
                                #if os(visionOS) || targetEnvironment(macCatalyst)
                                .buttonBorderShape(.roundedRectangle)
                                .buttonStyle(.plain)
                                #endif
                            }
                            Spacer()
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 20)
                }
                
                if 3 < suggestions.count {
                    HStack {
                        Text("Based on Your Recent Activity")
                            .font(.headline)
                        Spacer()
                    }
                    .safeAreaPadding(.horizontal, 20)
                    .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(suggestions) { sprite in
                                NavigationLink(value: sprite.id) {
                                    TileThumbnail(tile: sprite.tiles[0])
                                }
                                #if os(visionOS) || targetEnvironment(macCatalyst)
                                .buttonBorderShape(.roundedRectangle)
                                .buttonStyle(.plain)
                                #endif
                            }
                            Spacer()
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 20)
                }
                
                Spacer()
                    .frame(height: 20)
            }
        }
        .background(Color(UIColor.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        .navigationTitle("Browse")
    }
}

#Preview {
    BrowseView()
}
