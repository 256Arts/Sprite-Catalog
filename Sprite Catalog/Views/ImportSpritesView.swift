//
//  ImportSpritesView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-04-03.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportSpritesView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var importer: SpriteImporter
    
    @State var showingImport = false
    @State var showingImportError = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Artist Display Name", text: $importer.artistName)
                        .disableAutocorrection(true)
                    Picker("Licence", selection: $importer.licence) {
                        ForEach([Licence.cc0, .attribution, .attributionShareAlike, .attributionNonCommercial]) { (licence) in
                            Text("\(licence.name) (\(licence.rawValue))")
                                .tag(licence)
                        }
                        Divider()
                        Text("N/A")
                            .tag(Licence.none)
                    }
                    Picker("Category", selection: $importer.defaultCategory) {
                        ForEach(SpriteImporter.categories) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                    Toggle("Black Outline", isOn: $importer.blackOutline)
                    Toggle("Limited Palette", isOn: $importer.limitedPalette)
                    Toggle("Import Filenames", isOn: $importer.importFilenames)
                }
                Section {
                    Button(importer.spriteConfigs.isEmpty ? "Select sprites..." : "\(importer.spriteConfigs.count) sprites selected...") {
                        showingImport = true
                    }
                }
            }
            .navigationTitle("Import Sprites")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink("Next", destination: ImportSpritesDetailsView(importer: importer))
                        .disabled(importer.artistName.isEmpty || importer.spriteConfigs.isEmpty || (importer.debugMode && importer.licence == .none))
                }
            }
            .fileImporter(isPresented: $showingImport, allowedContentTypes: [.image], allowsMultipleSelection: true, onCompletion: { result in
                guard let urls = try? result.get() else {
                    showingImportError = true
                    return
                }
                importer.importFiles(at: urls)
            })
            .alert("Import Error", isPresented: $showingImportError) {
                Button("OK") { }
            }
        }
        .interactiveDismissDisabled(!importer.artistName.isEmpty || !importer.spriteConfigs.isEmpty)
        .onDisappear {
            do {
                try importer.clearImportedDirectory()
            } catch {
                print("Failed to clear temp")
            }
        }
    }
    
}

struct ImportSpritesView_Previews: PreviewProvider {
    static var previews: some View {
        ImportSpritesView(importer: .init(debugMode: false))
    }
}
