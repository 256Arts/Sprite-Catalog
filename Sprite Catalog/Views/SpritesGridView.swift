//
//  ContentView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-03-24.
//

import SwiftUI

struct SpritesGridView: View {
    
    @ObservedObject var filterSettings: FilterSettings = .shared
    
    let title: String
    let sprites: [SpriteSet]
    
    @State var filteredSprites: [SpriteSet] = []
    @State var searchText = ""
    @State var searchAll = false
    
    var body: some View {
        ScrollView {
            if title == "Artwork" {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))]) {
                    ForEach(filteredSprites) { sprite in
                        NavigationLink(value: sprite.id) {
                            ArtworkTileThumbnail(tile: sprite.tiles.first!)
                        }
                        #if os(visionOS)
                        .buttonBorderShape(.roundedRectangle)
                        #elseif targetEnvironment(macCatalyst)
                        .buttonStyle(.plain)
                        #endif
                    }
                }
                .padding()
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64))]) {
                    ForEach(filteredSprites) { sprite in
                        NavigationLink(value: sprite.id) {
                            TileThumbnail(tile: sprite.tiles.first!)
                        }
                        #if os(visionOS)
                        .buttonBorderShape(.roundedRectangle)
                        #elseif targetEnvironment(macCatalyst)
                        .buttonStyle(.plain)
                        #endif
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        .searchable(text: $searchText)
        .searchScopes($searchAll, scopes: {
            Text("Search \(title)").tag(false)
            Text("Search All").tag(true)
        })
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Menu {
                Picker("Size", selection: $filterSettings.sizeFilter) {
                    Text("Any Size")
                        .tag(nil as FilterSettings.SizeCategory?)
                    ForEach(FilterSettings.SizeCategory.allCases) { sizeCategory in
                        Text(sizeCategory.title)
                            .tag(sizeCategory as FilterSettings.SizeCategory?)
                    }
                }
                .menuActionDismissBehavior(.disabled)
                
                Toggle("Black Outline", isOn: Binding(get: {
                    filterSettings.tagFilters.contains(.blackOutline)
                }, set: { newValue in
                    if newValue {
                        filterSettings.tagFilters.insert(.blackOutline)
                    } else {
                        filterSettings.tagFilters.remove(.blackOutline)
                    }
                }))
                .menuActionDismissBehavior(.disabled)
                
                Toggle("Animated", isOn: $filterSettings.animatedOnly)
                    .menuActionDismissBehavior(.disabled)
            } label: {
                Image(systemName: "line.horizontal.3.decrease.circle")
            }
        }
        .onAppear {
            refreshFilter()
        }
        .onChange(of: sprites) { _, newValue in
            refreshFilter(localSprites: newValue)
        }
        .onChange(of: searchText) {
            refreshFilter()
        }
        .onChange(of: searchAll) {
            refreshFilter()
        }
        .onChange(of: filterSettings.sizeFilter) {
            refreshFilter()
        }
        .onChange(of: filterSettings.animatedOnly) {
            refreshFilter()
        }
        .onChange(of: filterSettings.tagFilters) {
            refreshFilter()
        }
    }
    
    func refreshFilter(localSprites: [SpriteSet]? = nil) {
        if !searchText.isEmpty, searchAll {
            filteredSprites = SpriteSet.allSprites
        } else {
            filteredSprites = localSprites ?? sprites
        }
        if filterSettings.animatedOnly {
            filteredSprites = filteredSprites.filter({ 1 < $0.tiles[0].variants[0].frameCount ?? 1 })
        }
        if !filterSettings.tagFilters.isEmpty {
            filteredSprites = filteredSprites.filter({ $0.tags.isSuperset(of: filterSettings.tagFilters) })
        }
        if !searchText.isEmpty {
            let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            filteredSprites = filteredSprites.filter({ $0.name.localizedCaseInsensitiveContains(trimmedSearch) })
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

#Preview {
    SpritesGridView(title: "All", sprites: [])
}
