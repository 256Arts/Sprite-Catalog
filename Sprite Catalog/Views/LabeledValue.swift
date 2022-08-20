//
//  LabeledValue.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-03-24.
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
                    .font(Font.callout)
            } else {
                Text(value)
                    .font(Font.callout)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
        }
    }
}

struct LabeledValue_Previews: PreviewProvider {
    static var previews: some View {
        LabeledValue(value: "Jayden", label: "Author")
    }
}
