//
//  SpriteDetailView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-03-24.
//

import SwiftUI
import StoreKit
import JaydenCodeGenerator

struct SpriteDetailView: View {
    
    enum OpenSpritePencilError: Error {
        case failedToGetSharedContainer
        case failedToRotateHueOrCreateImageData
    }
    
    let timer = Timer.publish(every: 0.3, on: .main, in: .default).autoconnect()
    
    @AppStorage(UserDefaults.Key.spritesViewed) var spritesViewed = 0
    @AppStorage(UserDefaults.Key.spritesEdited) var spritesEdited = 0
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.openURL) var openURL
    
    @ObservedObject var myCollection = SpriteCollection.myCollection
    @ObservedObject var stickersCollection = SpriteCollection.stickersCollection
    
    @State var sprite: SpriteSet
    @State var stateIndex: Int = 0
    @State var frame: Int = 0
    @State var hueRotationDegrees = 0.0
    @State var showingFullscreen = false
    @State var showingExport = false
    @State var showingHueRotationPopover = false
    @State var showingHueRotationRow = false
    @State var showingJaydenCode = false
    
    var jaydenCode: String {
        JaydenCodeGenerator.generateCode(secret: "R2FB47ULFA")
    }
    
    var body: some View {
        ScrollView {
            Image(uiImage: sprite.states[stateIndex].variants.first!.frameImages()[frame])
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
                    showingFullscreen = true
                }
                .onDrag {
                    NSItemProvider(object: UIImage(named: sprite.states[stateIndex].variants.first!.imageName)!)
                }
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Button(action: {
                        do {
                            try openInSpritePencil()
                        } catch {
                            print(error)
                        }
                    }, label: {
                        Text("Edit in Sprite Pencil")
                            .font(Font.system(size: 20, weight: .medium, design: .default))
                            .frame(idealWidth: .infinity, maxWidth: .infinity)
                    })
                    .buttonStyle(.borderedProminent)
                    Button(action: {
                        showingExport = true
                    }, label: {
                        Image(systemName: "folder")
                            .font(Font.system(size: 20, weight: .medium, design: .default))
                            .frame(width: 20, height: 24)
                    })
                    Button(action: {
                        showShareSheet()
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(Font.system(size: 20, weight: .medium, design: .default))
                            .frame(width: 20, height: 24)
                    })
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                if 1 < sprite.states.count {
                    Text("States")
                        .font(.title2)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(sprite.states.indices) { stateIndex in
                                Button {
                                    self.stateIndex = stateIndex
                                } label: {
                                    TileThumbnail(tile: sprite.states[stateIndex])
                                }
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
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    }
                }
                if sprite.tiles.contains(where: { $0.connectedEdges != nil }) {
                    Label("Connected Tileset", systemImage: "square.grid.3x3.middle.fill")
                        .font(Font.system(size: 17))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                if sprite.states.first?.variants.count != 1 {
                    Label("Multiple Random Variants", systemImage: "square.fill.on.square.fill")
                        .font(Font.system(size: 17))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                VStack(alignment: .leading) {
                    Text("Artist")
                    NavigationLink(sprite.artist.name, destination: CollectionView(collection: SpriteCollection(artist: sprite.artist), webpageURL: sprite.artist.url))
                        .font(Font.callout)
                }
                LabeledValue(value: sprite.licence.name, label: "Licence", url: sprite.licence.url)
            }
            .padding()
            VStack(alignment: .leading) {
                Text("Related")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64))]) {
                    ForEach(sprite.relatedSprites().prefix(10)) { sprite in
                        NavigationLink(destination: SpriteDetailView(sprite: sprite)) {
                            TileThumbnail(tile: sprite.tiles.first!)
                        }
                    }
                }
            }
            .padding()
            .frame(idealWidth: .infinity, maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
        }
        .navigationTitle(sprite.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                #if DEBUG
                Button {
                    UIPasteboard.general.string = sprite.id
                } label: {
                    Image(systemName: "number.square")
                }
                #endif
                Menu {
                    Button(action: {
                        if myCollection.spriteIDs.contains(sprite.id) {
                            myCollection.spriteIDs.remove(sprite.id)
                        } else {
                            myCollection.spriteIDs.insert(sprite.id)
                            if myCollection.spriteIDs == ["kuuznq", "w98ngk"] {
                                showingJaydenCode = true
                            }
                        }
                        do {
                            try myCollection.save(to: SpriteCollection.myCollectionFileURL)
                        } catch { }
                    }, label: {
                        Label("My Collection", systemImage: myCollection.spriteIDs.contains(sprite.id) ? "checkmark" : "")
                    })
                    Button(action: {
                        if stickersCollection.spriteIDs.contains(sprite.id) {
                            stickersCollection.spriteIDs.remove(sprite.id)
                        } else {
                            stickersCollection.spriteIDs.insert(sprite.id)
                        }
                        do {
                            try stickersCollection.save(to: SpriteCollection.stickersCollectionFileURL)
                            try stickersCollection.saveStickers()
                        } catch { }
                    }, label: {
                        Label("Stickers", systemImage: stickersCollection.spriteIDs.contains(sprite.id) ? "checkmark" : "")
                    })
                } label: {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                }
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
        }
        .fullScreenCover(isPresented: $showingFullscreen, content: {
            FullscreenSpriteView(sprite: sprite)
        })
        .alert("Secret Code: \(jaydenCode)", isPresented: $showingJaydenCode) {
            Button("Copy") {
                UIPasteboard.general.string = jaydenCode
            }
            Button("OK", role: .cancel, action: { })
        }
        .fileExporter(isPresented: $showingExport, documents: sprite.exportImageDocuments(), contentType: .png) { result in
            //
        }
        .userActivity(NSUserActivity.viewSprite, { activity in
            activity.title = sprite.name
            activity.persistentIdentifier = sprite.id
            activity.webpageURL = URL(string: "https://www.spritecatalog.com/#\(sprite.id)")
            activity.isEligibleForSearch = true
            activity.isEligibleForPrediction = true
            activity.isEligibleForPublicIndexing = true
        })
        .onAppear {
            UserDefaults.standard.addSuggestion(basedOn: sprite)
            spritesViewed += 1
            if (spritesViewed == 25 || spritesViewed == 100) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
        .onChange(of: sizeClass, perform: { (sizeClass) in
            showingHueRotationPopover = false
            showingHueRotationRow = false
        })
        .onReceive(timer) { (_) in
            guard let frameCount = sprite.states[stateIndex].variants.first?.frameCount, 1 < frameCount else { return }
            if frame + 1 == frameCount {
                frame = 0
            } else {
                frame += 1
            }
        }
    }
    
    func openInSpritePencil() throws {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Sprite_CatalogApp.spritePencilAppGroupID) else {
            throw OpenSpritePencilError.failedToGetSharedContainer
        }
        guard let data = UIImage(named: sprite.states[stateIndex].variants.first!.imageName)?.hueRotate(angle: hueRotationDegrees)?.pngData() else {
            throw OpenSpritePencilError.failedToRotateHueOrCreateImageData
        }
        try data.write(to: containerURL.appendingPathComponent("Import").appendingPathExtension("png"))
        let appGroupDefaults = UserDefaults(suiteName: Sprite_CatalogApp.spritePencilAppGroupID)
        appGroupDefaults?.set(sprite.name, forKey: "importSpriteName")
        openURL(URL(string: "https://www.jaydenirwin.com/spritepencil/importfromapp/")!)
        spritesEdited += 1
        if spritesEdited == 5 || spritesEdited == 30 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    func showShareSheet() {
        guard let shareImage = UIImage(named: sprite.states[stateIndex].variants.first!.imageName)?.hueRotate(angle: hueRotationDegrees) else { return }
        let previewImage = sprite.states[stateIndex].variants.first?.frameImage(frame: 0).hueRotate(angle: hueRotationDegrees)
        let items: [Any] = [shareImage, ShareTextSource(image: previewImage, title: sprite.name)]
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            av.popoverPresentationController?.sourceView = rootVC.view
            av.popoverPresentationController?.sourceRect = rootVC.view.bounds
            av.popoverPresentationController?.permittedArrowDirections = []
            rootVC.present(av, animated: true, completion: nil)
        }
    }
    
}

struct SpriteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SpriteDetailView(sprite: SpriteSet(id: "xxxxxx", name: "Title", artist: Artist(name: "Jayden"), licence: .cc0, layer: .object, tags: [], tiles: [.init(variants: [.init(imageName: "")])]))
    }
}
