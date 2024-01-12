//
//  FontsGridView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2023-05-26.
//

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
                    #if os(visionOS)
                    .buttonBorderShape(.roundedRectangle)
                    #elseif targetEnvironment(macCatalyst)
                    .buttonStyle(.plain)
                    #endif
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        .searchable(text: $searchText)
        .navigationTitle("Fonts")
        .navigationBarTitleDisplayMode(.inline)
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
                .font(.custom(family.fontNames.first ?? "", size: family.displaySize * 2.5))
                .foregroundColor(.primary)
                .fixedSize(horizontal: true, vertical: true)
        }
        .aspectRatio(1, contentMode: .fit)
        .draggable(family.fonts.first!)
        #else
        Color(uiColor: .secondarySystemGroupedBackground)
        .overlay {
            Text("Aa")
                .font(.custom(family.fontNames.first ?? "", size: family.displaySize * 2.5))
                .foregroundColor(.primary)
                .fixedSize(horizontal: true, vertical: true)
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(16)
        .draggable(family.fonts.first!)
        #endif
    }
}

#Preview {
    FontsGridView()
}
