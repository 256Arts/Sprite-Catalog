//
//  FilterView.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-03-25.
//

import SwiftUI

struct FilterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var filterSettings: FilterSettings
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Size".uppercased())) {
                    Button {
                        if filterSettings.sizeFilter == .lessThan16 {
                            filterSettings.sizeFilter = nil
                        } else {
                            filterSettings.sizeFilter = .lessThan16
                        }
                    } label: {
                        HStack {
                            Text("Small")
                                .foregroundColor(.primary)
                            if filterSettings.sizeFilter == .lessThan16 {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button {
                        if filterSettings.sizeFilter == .equal16 {
                            filterSettings.sizeFilter = nil
                        } else {
                            filterSettings.sizeFilter = .equal16
                        }
                    } label: {
                        HStack {
                            Text("Medium (16x16)")
                                .foregroundColor(.primary)
                            if filterSettings.sizeFilter == .equal16 {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button {
                        if filterSettings.sizeFilter == .moreThan16 {
                            filterSettings.sizeFilter = nil
                        } else {
                            filterSettings.sizeFilter = .moreThan16
                        }
                    } label: {
                        HStack {
                            Text("Large")
                                .foregroundColor(.primary)
                            if filterSettings.sizeFilter == .moreThan16 {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Section {
                    Toggle("Black Outline", isOn: Binding(get: {
                        filterSettings.tagFilters.contains(.blackOutline)
                    }, set: { newValue in
                        if newValue {
                            filterSettings.tagFilters.insert(.blackOutline)
                        } else {
                            filterSettings.tagFilters.remove(.blackOutline)
                        }
                    }))
                    Toggle("Animated", isOn: Binding(get: {
                        filterSettings.animatedOnly
                    }, set: { newValue in
                        filterSettings.animatedOnly = newValue
                    }))
                }
//                Button {
//                    //
//                } label: {
//                    Label("Top Down", systemImage: "arrow.down.square")
//                }
//                Button {
//                    //
//                } label: {
//                    Label("Side View", systemImage: "arrow.right.square")
//                }
//                Button {
//                    //
//                } label: {
//                    Label("Isometric", systemImage: "diamond")
//                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filterSettings.sizeFilter = nil
                        filterSettings.animatedOnly = false
                        filterSettings.tagFilters.removeAll()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(filterSettings: FilterSettings.shared)
    }
}
