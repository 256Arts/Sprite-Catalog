//
//  LabeledValue.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2021-03-24.
//

import SwiftUI

struct LabeledValue: View {
    
    @State var value: String
    @State var label: String
    @State var url: URL?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
            if let url = url {
                Link(value, destination: url)
                    .buttonStyle(.borderless)
                    .font(Font.callout)
            } else {
                Text(value)
                    .font(Font.callout)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
    }
}

#Preview {
    LabeledValue(value: "Jayden", label: "Author")
}
