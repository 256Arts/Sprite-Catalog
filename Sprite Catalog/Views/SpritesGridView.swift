//
//  ContentView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-03-24.
//

import SwiftUI

struct SpritesGridView: View {
    
    @ObservedObject var filterSettings: FilterSettings = .shared
    
    @State var title: String
    @State var sprites: [SpriteSet]
    @State var filteredSprites: [SpriteSet] = []
    @State var showingFilters = false
    @State var searchText = ""
    
    var body: some View {
        ScrollView {
            if title == "Artwork" {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))]) {
                    ForEach(filteredSprites) { sprite in
                        NavigationLink(destination: SpriteDetailView(sprite: sprite)) {
                            ArtworkTileThumbnail(tile: sprite.tiles.first!)
                        }
                    }
                }
                .padding()
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64))]) {
                    ForEach(filteredSprites) { sprite in
                        NavigationLink(destination: SpriteDetailView(sprite: sprite)) {
                            TileThumbnail(tile: sprite.tiles.first!)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .searchable(text: $searchText)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                showingFilters = true
            } label: {
                Image(systemName: "line.horizontal.3.decrease.circle")
            }
        }
        .onAppear() {
            refreshFilter()
        }
        .onChange(of: searchText, perform: { _ in
            refreshFilter()
        })
        .onChange(of: filterSettings.sizeFilter, perform: { _ in
            refreshFilter()
        })
        .onChange(of: filterSettings.animatedOnly, perform: { _ in
            refreshFilter()
        })
        .onChange(of: filterSettings.tagFilters, perform: { _ in
            refreshFilter()
        })
        .sheet(isPresented: $showingFilters) {
            FilterView(filterSettings: filterSettings)
        }
    }
    
    func refreshFilter() {
        filteredSprites = sprites
        if filterSettings.animatedOnly {
            filteredSprites = filteredSprites.filter({ 1 < $0.tiles[0].variants[0].frameCount ?? 1 })
        }
        if !filterSettings.tagFilters.isEmpty {
            filteredSprites = filteredSprites.filter({ $0.tags.isSuperset(of: filterSettings.tagFilters) })
        }
        if !searchText.isEmpty {
            filteredSprites = filteredSprites.filter({ $0.name.lowercased().contains(searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) })
        }
        if filterSettings.sizeFilter != nil {
            filteredSprites = filteredSprites.filter({
                let size = $0.tiles.first!.variants.first!.frameImage().size
                if size == CGSize(width: 16, height: 16) {
                    return (filterSettings.sizeFilter == .equal16)
                } else if 16 < size.width || 16 < size.height {
                    return (filterSettings.sizeFilter == .moreThan16)
                } else {
                    return (filterSettings.sizeFilter == .lessThan16)
                }
            })
        }
    }
    
}

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        SpritesGridView(title: "All", sprites: [])
    }
}
