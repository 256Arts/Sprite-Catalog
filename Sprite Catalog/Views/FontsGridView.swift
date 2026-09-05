import SwiftUI

struct FontsGridView: View {
    
    @State var filteredFamilies: [FontFamily] = FontFamily.allFamilies
    @State var searchText = ""
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))]) {
                ForEach(filteredFamilies) { family in
                    NavigationLink(value: family) {
                        FontThumbnail(family: family)
                    }
                    .cellButtonStyle()
                }
            }
            .padding()
        }
        .background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
        .searchable(text: $searchText)
        .navigationTitle("Fonts")
        .navigationTitleDisplayMode(.inline)
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
                filteredFamilies = FontFamily.allFamilies
            } else {
                let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                filteredFamilies = filteredFamilies.filter({ $0.name.localizedCaseInsensitiveContains(trimmedValue) })
            }
        }
    }
}

struct FontThumbnail: View {
    
    @State var family: FontFamily
    
    var body: some View {
        #if os(visionOS)
        Color.clear
        .overlay {
            Text("Aa")
                .font(family.previewFont(scale: 2.5))
                .foregroundColor(.primary)
                .fixedSize(horizontal: true, vertical: true)
        }
        .aspectRatio(1, contentMode: .fit)
        .draggable(family.fonts[0])
        #else
        Color.groupedCellBackground
        .overlay {
            Text("Aa")
                .font(family.previewFont(scale: 2.5))
                .foregroundColor(.primary)
                .fixedSize(horizontal: true, vertical: true)
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(16)
        .draggable(family.fonts[0])
        #endif
    }
}

#Preview {
    FontsGridView()
}
