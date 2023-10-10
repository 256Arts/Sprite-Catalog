//
//  CutterView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2023-10-08.
//

import SwiftUI

struct CutterView: View, DropDelegate {
    
    #if targetEnvironment(macCatalyst)
    let isCatalyst = true
    #else
    let isCatalyst = false
    #endif
    
    @Environment(\.dismiss) private var dismiss
    
    @State var cutter = Cutter()
    
    @State var showingImport = false
    @State var showingImportError = false
    @State var showingExport = false
    @State var showingExportError = false
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                if let image = cutter.image {
                    Image(uiImage: image)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(idealWidth: .infinity, maxWidth: .infinity, idealHeight: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.down")
                            .font(Font.system(size: 100, weight: .medium))
                        Text("Drop spritesheet here")
                            .bold()
                    }
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .frame(idealWidth: .infinity, maxWidth: .infinity, idealHeight: .infinity, maxHeight: .infinity)
                }
            }
            .onTapGesture {
                showingImport = true
            }
            .onDrop(of: [.image], delegate: self)
            #if targetEnvironment(macCatalyst)
            Divider()
            #endif
            VStack {
                HStack {
                    Text("Sprite Size:")
                        .font(Font.system(size: isCatalyst ? 13 : 18, weight: isCatalyst ? .regular : .bold))
                        .foregroundColor(Color(isCatalyst ? UIColor.secondaryLabel : UIColor.label))
                    Spacer()
                    IntField(title: "Width", value: $cutter.spriteSize.width)
                    Text("x")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    IntField(title: "Height", value: $cutter.spriteSize.height)
                }
                HStack {
                    Text("Number of Sprites:")
                        .font(Font.system(size: isCatalyst ? 13 : 18, weight: isCatalyst ? .regular : .bold))
                        .foregroundColor(Color(isCatalyst ? UIColor.secondaryLabel : UIColor.label))
                    Spacer()
                    IntField(title: "Columns", value: $cutter.spriteCounts.x)
                    Text("x")
                        .foregroundColor(Color(UIColor.secondaryLabel))
                    IntField(title: "Rows", value: $cutter.spriteCounts.y)
                }
                HStack {
                    Text("Spacing:")
                        .font(Font.system(size: isCatalyst ? 13 : 18, weight: isCatalyst ? .regular : .bold))
                        .foregroundColor(Color(isCatalyst ? UIColor.secondaryLabel : UIColor.label))
                    Spacer()
                    #if targetEnvironment(macCatalyst)
                    IntField(title: "Spacing", value: $cutter.spacing)
                    #else
                    Text("\(cutter.spacing)")
                    Stepper("Spacing", value: $cutter.spacing)
                        .labelsHidden()
                    #endif
                }
            }
            .padding()
            #if targetEnvironment(macCatalyst)
            Divider()
            HStack {
                Spacer()
                Button("Cut") {
                    showingExport = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!cutter.canCut)
            }
            .padding()
            #else
            Button {
                showingExport = true
            } label: {
                Text("Cut")
                    .font(.headline)
                    .frame(idealWidth: .infinity, maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!cutter.canCut)
            .padding()
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        #if targetEnvironment(macCatalyst)
        .navigationBarHidden(true)
        #endif
        .fileImporter(isPresented: $showingImport, allowedContentTypes: [.image], onCompletion: { result in
            guard let url = try? result.get(), url.startAccessingSecurityScopedResource(), let image = UIImage(contentsOfFile: url.path) else {
                showingImportError = true
                return
            }
            url.stopAccessingSecurityScopedResource()
            cutter.image = image
        })
        .fileExporter(isPresented: $showingExport, documents: (try? cutDocuments()) ?? [], contentType: .png) { result in
            //
        }
        .alert("Import Error", isPresented: $showingImportError) {
            Button("OK") { }
        }
        .alert("Export Error", isPresented: $showingExportError) {
            Button("OK") { }
        }
    }
    
    func cutDocuments() throws -> [ImageDocument] {
        var documents: [ImageDocument] = []
        for (index, image) in try cutter.cut().enumerated() {
            documents.append(.init(image: image, filename: "Sprite \(index + 1)"))
        }
        return documents
    }
    
    func performDrop(info: DropInfo) -> Bool {
        let items = info.itemProviders(for: [.image])
        for item in items {
            item.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    self.cutter.image = image as? UIImage
                }
            }
        }
        return true
    }
    
}

#Preview {
    CutterView()
}
