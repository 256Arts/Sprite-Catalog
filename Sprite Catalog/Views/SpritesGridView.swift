import SwiftUI

struct SpritesGridView: View {
    
    @Bindable var filterSettings: FilterSettings = .shared
    
    let title: String
    let sprites: [SpriteSet]
    
    @State var filteredSprites: [SpriteSet] = []
    @State var searchText = ""
    @State var searchAll = false
    @State private var selection = SpriteSelection()
    @State private var exporting: [SpriteSet] = []
    @State private var perspectives: [SpriteSet.Tag] = []
    
    private var isArtwork: Bool {
        title == "Artwork"
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: isArtwork ? 140 : 64))]) {
                ForEach(filteredSprites) { sprite in
                    SpriteGridCell(sprite: sprite, isArtwork: isArtwork, selection: selection) { exporting = $0 }
                }
            }
            .padding()
        }
        .background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
        .searchable(text: $searchText)
        .searchScopes($searchAll, scopes: {
            Text("Search \(title)").tag(false)
            Text("Search All").tag(true)
        })
        .navigationTitle(title)
        .navigationTitleDisplayMode(.inline)
        .spriteSelectionToolbar(selection, displaying: filteredSprites, exporting: $exporting)
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
                .keepsMenuOpen()
                
                if !perspectives.isEmpty {
                    Picker("Perspective", selection: $filterSettings.perspective) {
                        Text("Any Perspective")
                            .tag(nil as SpriteSet.Tag?)
                        ForEach(perspectives) { perspective in
                            Text(perspective.title)
                                .tag(perspective as SpriteSet.Tag?)
                        }
                    }
                    .keepsMenuOpen()
                }
                
                tagToggle(.blackOutline)
                tagToggle(.limitedPalette)
                
                Toggle("Animated", isOn: $filterSettings.animatedOnly)
                    .keepsMenuOpen()
            } label: {
                Label("Filter", systemImage: filterSettings.isFiltering ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease")
                    .labelStyle(.iconOnly)
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
    
    private func tagToggle(_ tag: SpriteSet.Tag) -> some View {
        Toggle(isOn: Binding(get: {
            filterSettings.tagFilters.contains(tag)
        }, set: { newValue in
            if newValue {
                filterSettings.tagFilters.insert(tag)
            } else {
                filterSettings.tagFilters.remove(tag)
            }
        })) {
            Text(tag.title)
        }
        .keepsMenuOpen()
    }
    
    func refreshFilter(localSprites: [SpriteSet]? = nil) {
        if !searchText.isEmpty, searchAll {
            filteredSprites = SpriteSet.allSprites
        } else {
            filteredSprites = localSprites ?? sprites
        }
        // Only offer perspectives this screen's sprites are drawn in, plus the one already picked so it can be cleared.
        perspectives = SpriteSet.Tag.perspectives.filter { perspective in
            perspective == filterSettings.perspective || filteredSprites.contains { $0.tags.contains(perspective) }
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
                let size = $0.tiles[0].variants[0].frameSize
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
