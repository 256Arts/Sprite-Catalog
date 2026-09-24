import SwiftUI
import StoreKit

struct SpriteDetailView: View {
    
    enum OpenSpritePencilError: Error {
        case failedToGetSharedContainer
    }
    
    let timer = Timer.publish(every: 0.3, on: .main, in: .default).autoconnect()
    
    @AppStorage(UserDefaults.Key.spritesViewed) var spritesViewed = 0
    @AppStorage(UserDefaults.Key.spritesEdited) var spritesEdited = 0
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.openURL) var openURL
    @Environment(\.openWindow) var openWindow
    @Environment(\.requestReview) private var requestReview
    
    @State var sprite: SpriteSet
    @State private var relatedSprites: [SpriteSet] = []
    @State var stateIndex: Int = 0
    @State var frame: Int = 0
    @State var hueRotationDegrees = 0.0
    @State var showingFullscreen = false
    @State private var exporting: [SpriteSet] = []
    @State var showingHueRotationPopover = false
    @State var showingHueRotationRow = false
    
    var transferableImage: Image? {
        let original = sprite.states[stateIndex].variants[0].cgImage
        guard let filteredImage = try? original.hueRotated(angle: hueRotationDegrees) else { return nil }

        return Image(sprite: filteredImage)
    }

    #if DEBUG
    private var copyIDButton: some View {
        Button("Copy ID", systemImage: "number.square") {
            Clipboard.copy(sprite.id)
        }
    }
    #endif

    /// Pinning a toolbar item beside the title arrived in OS 27; before that it just trails. macOS
    /// has no top bar at all, so it takes the window toolbar's leading action slot.
    private var addToCollectionPlacement: ToolbarItemPlacement {
        #if os(macOS)
        .primaryAction
        #else
        if #available(iOS 27.0, visionOS 27.0, *) {
            .topBarPinnedTrailing
        } else {
            .topBarTrailing
        }
        #endif
    }

    private var addToCollectionMenu: some View {
        Menu("Add to...", systemImage: "folder.badge.plus") {
            SpriteCollectionButtons(sprites: [sprite])
        }
    }

    private var recolorButton: some View {
        Button {
            if sizeClass == .regular {
                showingHueRotationPopover = true
            } else {
                showingHueRotationRow.toggle()
            }
        } label: {
            Image("Color Wheel")
        }
    }
    
    var body: some View {
        ScrollView {
            Image(sprite: sprite.states[stateIndex].variants[0].frameImages()[frame])
                .resizable()
                .interpolation(.none)
                .hueRotation(Angle.degrees(hueRotationDegrees))
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                .popover(isPresented: $showingHueRotationPopover) {
                    VStack {
                        Text("Quick Recolor")
                            .font(Font.headline)
                        Slider(value: $hueRotationDegrees, in: 0...360)
                            .frame(width: 256)
                    }
                    .padding()
                }
                .onTapGesture {
                    #if os(macOS)
                    openWindow(value: sprite.id)
                    #else
                    showingFullscreen = true
                    #endif
                }
                .draggable(sprite.transfer(of: sprite.states[stateIndex], hueRotationDegrees: hueRotationDegrees))
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Button {
                        do {
                            try openInSpritePencil()
                        } catch {
                            print(error)
                        }
                    } label: {
                        Text("Edit in Sprite Pencil")
                            .font(Font.system(size: 20, weight: .medium, design: .default))
                            .frame(idealWidth: .infinity, maxWidth: .infinity)
                    }
                    #if os(visionOS)
                    .buttonStyle(.borderedProminent)
                    #else
                    .buttonStyle(.glassProminent)
                    #endif
                    saveAndShareButton()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                if 1 < sprite.states.count {
                    Text("States")
                        .font(.title2)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(sprite.states.indices, id: \.self) { stateIndex in
                                Button {
                                    self.stateIndex = stateIndex
                                } label: {
                                    TileThumbnail(tile: sprite.states[stateIndex])
                                }
                                .cellButtonStyle()
                                .draggable(sprite.transfer(of: sprite.states[stateIndex]))
                            }
                        }
                        .padding()
                    }
                    .padding(-16)
                }
                
                if showingHueRotationRow {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quick Recolor")
                            .font(Font.headline)
                        Slider(value: $hueRotationDegrees, in: 0...360)
                    }
                }
                
                if !sprite.tiles.compactMap({ $0.facing }).isEmpty {
                    VStack(alignment: .leading) {
                        Text("Directions")
                        HStack {
                            ForEach(Array(Set(sprite.tiles.compactMap({ $0.facing }))).sorted()) { (direction) in
                                Image(systemName: "arrow.\(direction.rawValue).square.fill")
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                if sprite.tiles.contains(where: { $0.connectedEdges != nil }) {
                    Label("Connected Tileset", systemImage: "square.grid.3x3.middle.fill")
                        .font(Font.system(size: 17))
                        .foregroundColor(.secondary)
                }
                
                if sprite.states.first?.variants.count != 1 {
                    Label("Multiple Random Variants", systemImage: "square.fill.on.square.fill")
                        .font(Font.system(size: 17))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("Artist")
                    NavigationLink(sprite.artist.name, value: sprite.artist)
                        .buttonStyle(.borderless)
                        .font(Font.callout)
                }
                
                LabeledValue(value: String(localized: sprite.licence.name), label: "Licence", url: sprite.licence.url)
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("Related")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64))]) {
                    ForEach(relatedSprites) { sprite in
                        SpriteGridCell(sprite: sprite) { exporting = $0 }
                    }
                }
            }
            .padding()
            .frame(idealWidth: .infinity, maxWidth: .infinity)
            .background {
                Color.secondaryBackground
                    .padding(.bottom, -32)
                    .backgroundExtensionEffect()
            }
        }
        .navigationTitle(sprite.name)
        .navigationTitleDisplayMode(.inline)
        // Tells the menu bar which sprite its Sprite menu acts on.
        .focusedSceneValue(\.spriteID, sprite.id)
        .task(id: sprite.id) {
            relatedSprites = Array(sprite.relatedSprites().prefix(10)) // Instant heuristic
            relatedSprites = await sprite.suggestedRelatedSprites()    // Refined by Apple Intelligence when available
        }
        .toolbar {
            #if DEBUG
            #if os(macOS)
            ToolbarItem(placement: .secondaryAction) {
                copyIDButton
            }
            #else
            if #available(iOS 27.0, visionOS 27.0, *) {
                ToolbarOverflowMenu {
                    copyIDButton
                }
            } else {
                ToolbarItem(placement: .secondaryAction) {
                    copyIDButton
                }
            }
            #endif
            #endif
            ToolbarItem(placement: addToCollectionPlacement) {
                addToCollectionMenu
            }
            #if os(macOS)
            ToolbarItem(placement: .automatic) {
                recolorButton
            }
            #elseif os(visionOS)
            ToolbarItem(placement: .topBarTrailing) {
                recolorButton
            }
            #else
            if #available(iOS 27.0, *) {
                ToolbarItem(placement: .topBarTrailing) {
                    recolorButton
                }
                .visibilityPriority(.low)
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    recolorButton
                }
            }
            #endif
        }
        #if !os(macOS)
        // A Mac opens the sprite in its own window instead, from the tap above.
        .fullScreenCover(isPresented: $showingFullscreen) {
            FullscreenSpriteView(sprite: sprite)
        }
        #endif
        .spriteExporter($exporting)
        .userActivity(NSUserActivity.viewSprite, { activity in
            activity.title = sprite.name
            activity.persistentIdentifier = sprite.id
            activity.webpageURL = URL(string: "https://www.spritecatalog.com/#\(sprite.id)")
            activity.isEligibleForSearch = true
            activity.isEligibleForPublicIndexing = true
            #if !os(macOS)
            // Siri only predicts activities on the platforms that suggest them.
            activity.isEligibleForPrediction = true
            #endif
        })
        .onAppear {
            UserDefaults.standard.addSuggestion(basedOn: sprite)
            spritesViewed += 1
            if [20, 50, 100, 200, 500].contains(spritesViewed) {
                requestReview()
            }
        }
        .onChange(of: sizeClass) {
            showingHueRotationPopover = false
            showingHueRotationRow = false
        }
        .onReceive(timer) { (_) in
            guard let frameCount = sprite.states[stateIndex].variants.first?.frameCount, 1 < frameCount else { return }
            if frame + 1 == frameCount {
                frame = 0
            } else {
                frame += 1
            }
        }
    }
    
    private func saveAndShareButton() -> some View {
        Group {
            Button {
                exporting = [sprite]
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .font(Font.system(size: 20, weight: .medium, design: .default))
                    .frame(width: 20, height: 24)
            }
            
            if let transferableImage {
                ShareLink(item: transferableImage, subject: Text(sprite.name), message: Text("Found in Sprite Catalog"), preview: .init(sprite.name, icon: transferableImage)) {
                    Image(systemName: "square.and.arrow.up")
                        .font(Font.system(size: 20, weight: .medium, design: .default))
                        .frame(width: 20, height: 24)
                }
            }
        }
        .buttonBorderShape(.circle)
    }
    
    private func openInSpritePencil() throws {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Sprite_CatalogApp.spritePencilAppGroupID) else {
            throw OpenSpritePencilError.failedToGetSharedContainer
        }
        let data = try sprite.states[stateIndex].variants[0].cgImage.hueRotated(angle: hueRotationDegrees).pngData()
        try data.write(to: containerURL.appendingPathComponent("Import").appendingPathExtension("png"))
        let appGroupDefaults = UserDefaults(suiteName: Sprite_CatalogApp.spritePencilAppGroupID)
        appGroupDefaults?.set(sprite.name, forKey: "importSpriteName")
        openURL(URL(string: "https://www.256arts.com/spritepencil/importfromapp/")!)
        spritesEdited += 1
        if spritesEdited == 5 || spritesEdited == 30 {
            requestReview()
        }
    }
    
}

#Preview {
    SpriteDetailView(sprite: SpriteSet(id: "xxxxxx", name: "Title", artist: Artist(name: "Jayden"), licence: .cc0, layer: .object, tags: [], tiles: [.init(variants: [.init(imageName: "")])]))
}
