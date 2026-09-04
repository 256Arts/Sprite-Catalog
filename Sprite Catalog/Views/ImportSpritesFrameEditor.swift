import SwiftUI

struct ImportSpritesFrameEditor: View {
    
    @State var config: SpriteImporter.SpriteSetConfiguration
    
    var dividers: [UUID] {
        var all: [UUID] = []
        for _ in 1..<config.frameCount {
            all.append(UUID())
        }
        return all
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let cgImage = CGImage.loading(contentsOf: config.importedFileURLs[0]) {
                ZStack {
                    Image(sprite: cgImage)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                    HStack {
                        Spacer()
                        ForEach(dividers, id: \.self) { _ in
                            Color.red.frame(width: 2)
                            Spacer()
                        }
                    }
                }
            }
            HStack {
                Text("Frame Count: \(config.frameCount)")
                Spacer()
                Stepper("Frame Count", value: $config.frameCount, in: 1...20)
                    .labelsHidden()
            }
        }
        .padding()
        .toolbar {
            Button("Done") {
                //
            }
        }
    }
}

#Preview {
    ImportSpritesFrameEditor(config: .init(importedFileURLs: [], name: "", category: .miscItem))
}
