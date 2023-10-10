//
//  ImportSpritesDetailsView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-07-10.
//

import SwiftUI

struct ImportSpritesDetailsView: View {
    
    @ObservedObject var importer: SpriteImporter

    @State var frameEditorConfig: SpriteImporter.SpriteSetConfiguration?
    #if DEBUG
    @State var showingTutorial = false
    #endif
    
    var body: some View {
        List {
            ForEach($importer.spriteConfigs) { $config in
                HStack {
                    if let uiImage = UIImage(contentsOfFile: config.importedFileURLs.first!.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 48, height: 48)
                    }
                    TextField("Name", text: $config.name, onCommit: {
                        config.name = config.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        importer.objectWillChange.send()
                    })
                        .textInputAutocapitalization(.words)
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
            ToolbarItem(placement: .navigationBarTrailing) {
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
        .sheet(isPresented: $showingTutorial, content: {
            DebugImportSpritesTutorial()
        })
        #endif
    }
    
}

struct DebugImportSpritesDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ImportSpritesDetailsView(importer: SpriteImporter(debugMode: false))
    }
}
