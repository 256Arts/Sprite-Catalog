import SwiftUI

struct CutterView: View, DropDelegate {
    
    /// Desktop lays the cutter's controls out as a compact inspector rather than as the large
    /// touch controls an iPhone needs.
    #if os(macOS) || targetEnvironment(macCatalyst)
    let isDesktop = true
    #else
    let isDesktop = false
    #endif
    
    @Environment(\.dismiss) private var dismiss
    
    @State var cutter = Cutter(image: ScreenshotMode.demoSpritesheet)
    
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
                    Image(sprite: image)
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
                        .foregroundColor(.secondary)
                        .frame(idealWidth: .infinity, maxWidth: .infinity, idealHeight: .infinity, maxHeight: .infinity)
                }
            }
            .onTapGesture {
                showingImport = true
            }
            .onDrop(of: [.image], delegate: self)
            #if os(macOS) || targetEnvironment(macCatalyst)
            Divider()
            #endif
            VStack {
                HStack {
                    Text("Sprite Size:")
                        .font(Font.system(size: isDesktop ? 13 : 18, weight: isDesktop ? .regular : .bold))
                        .foregroundColor(isDesktop ? Color.secondary : Color.primary)
                    Spacer()
                    IntField(title: "Width", value: $cutter.spriteSize.width)
                    Text("x")
                        .foregroundColor(.secondary)
                    IntField(title: "Height", value: $cutter.spriteSize.height)
                }
                HStack {
                    Text("Number of Sprites:")
                        .font(Font.system(size: isDesktop ? 13 : 18, weight: isDesktop ? .regular : .bold))
                        .foregroundColor(isDesktop ? Color.secondary : Color.primary)
                    Spacer()
                    IntField(title: "Columns", value: $cutter.spriteCounts.x)
                    Text("x")
                        .foregroundColor(.secondary)
                    IntField(title: "Rows", value: $cutter.spriteCounts.y)
                }
                HStack {
                    Text("Spacing:")
                        .font(Font.system(size: isDesktop ? 13 : 18, weight: isDesktop ? .regular : .bold))
                        .foregroundColor(isDesktop ? Color.secondary : Color.primary)
                    Spacer()
                    #if os(macOS) || targetEnvironment(macCatalyst)
                    IntField(title: "Spacing", value: $cutter.spacing)
                    #else
                    Text("\(cutter.spacing)")
                    Stepper("Spacing", value: $cutter.spacing)
                        .labelsHidden()
                    #endif
                }
            }
            .padding()
            #if os(macOS) || targetEnvironment(macCatalyst)
            Divider()
            HStack {
                Spacer()
                Button("Cut", systemImage: "scissors") {
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
                Label("Cut", systemImage: "scissors")
                    .font(.headline)
                    .frame(idealWidth: .infinity, maxWidth: .infinity)
            }
            #if os(visionOS)
            .buttonStyle(.borderedProminent)
            #else
            .buttonStyle(.glassProminent)
            #endif
            .controlSize(.large)
            .disabled(!cutter.canCut)
            .padding()
            #endif
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
        }
        .fileImporter(isPresented: $showingImport, allowedContentTypes: [.image], onCompletion: { result in
            guard let url = try? result.get(), url.startAccessingSecurityScopedResource(), let image = CGImage.loading(contentsOf: url) else {
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
            item.loadObject(ofClass: PlatformImage.self) { (image, error) in
                let cgImage = (image as? PlatformImage)?.cgImage
                DispatchQueue.main.async {
                    self.cutter.image = cgImage
                }
            }
        }
        return true
    }
    
}

#Preview {
    CutterView()
}
