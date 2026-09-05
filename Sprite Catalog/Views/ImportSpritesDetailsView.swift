import SwiftUI

struct ImportSpritesDetailsView: View {
    
    @Bindable var importer: SpriteImporter

    @State var frameEditorConfig: SpriteImporter.SpriteSetConfiguration?
    #if DEBUG
    @State var showingTutorial = false
    @State private var showingDebugExport = false
    #endif
    
    var body: some View {
        List {
            ForEach($importer.spriteConfigs) { $config in
                HStack {
                    if let cgImage = CGImage.loading(contentsOf: config.importedFileURLs[0]) {
                        Image(sprite: cgImage)
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                    }
                    TextField("Name", text: $config.name, onCommit: {
                        config.name = config.name.trimmingCharacters(in: .whitespacesAndNewlines)
//                        importer.objectWillChange.send()
                    })
                        #if !os(macOS)
                        .textInputAutocapitalization(.words)
                        #endif
                    if 1 < config.importedFileURLs.count {
                        Text("\(config.importedFileURLs.count) States")
                    }
                    Picker("Category", selection: $config.category) {
                        ForEach(SpriteImporter.categories) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    #if DEBUG
                    Button {
                        frameEditorConfig = config
                    } label: {
                        if config.frameCount == 1 {
                            Image(systemName: "square.stack.3d.forward.dottedline")
                                .accessibilityLabel("\(config.frameCount) Frames")
                        } else {
                            Image(systemName: "\(config.frameCount).square")
                                .accessibilityLabel("\(config.frameCount) Frames")
                        }
                    }
                    #endif
                    Button {
                        importer.mergeWithAbove(config: config)
                    } label: {
                        Image(systemName: "arrow.turn.right.up")
                            .accessibilityLabel(Text("Merge With Above"))
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .navigationTitle("Import Sprites")
        .toolbar {
            #if DEBUG
            ToolbarItem(placement: .barTrailing) {
                Button {
                    showingTutorial = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
            #endif
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    do {
                        try importer.save()
                        #if DEBUG
                        showingDebugExport = !importer.debugExportURLs.isEmpty
                        #endif
                    } catch {
                        print(error)
                    }
                }
                .disabled(!importer.spriteConfigs.allSatisfy({ !$0.name.isEmpty }))
            }
        }
        .sheet(item: $frameEditorConfig) { config in
            NavigationStack {
                ImportSpritesFrameEditor(config: config)
            }
        }
        #if DEBUG
        .sheet(isPresented: $showingTutorial) {
            DebugImportSpritesTutorial()
        }
        // A debug import writes to the temporary directory; moving the files out is how they reach
        // the catalog's source.
        .fileMover(isPresented: $showingDebugExport, files: importer.debugExportURLs) { _ in }
        #endif
    }
    
}

#Preview {
    ImportSpritesDetailsView(importer: SpriteImporter(debugMode: false))
}
