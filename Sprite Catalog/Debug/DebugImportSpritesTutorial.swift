//
//  DebugImportSpritesTutorial.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-11-12.
//

#if DEBUG
import SwiftUI

struct DebugImportSpritesTutorial: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("1. Import sprites with this UI.")
                Text("2. Add variant metadata to \"WIP Sprites.json\" records if nessisary.")
                Text("3. Paste text from \"WIP Sprites.json\" into \"Z Catalog.json\".")
                Text("4. Drag image into assets in Xcode.")
                Text("5. Move image into App Assets ‣ Sprite Catalog ‣ Catalog folder.")
                Text("6. Add artist URL into \"Artist.swift\".")
                Text("7. Build app.")
                Text("8. Reorder in app if nessisary.")
            }
            .navigationTitle("Tutorial")
        }
    }
}

#Preview {
    DebugImportSpritesTutorial()
}
#endif
