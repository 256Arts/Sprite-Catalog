//
//  FamilyDetailView.swift
//  Sprite Catalog
//
//  Created by 256 Arts Developer on 2023-05-26.
//

import SwiftUI

struct FamilyDetailView: View {
    
    enum PreviewMode {
        case sample, custom
    }
    
    @ObservedObject var provider = FontProvider.shared
    
    @Binding var previewMode: PreviewMode
    @Binding var customString: String
    
    let family: FontFamily
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Preview Mode", selection: $previewMode) {
                    Image(systemName: "text.aligncenter")
                        .tag(PreviewMode.sample)
                    Image(systemName: "text.cursor")
                        .tag(PreviewMode.custom)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if previewMode == .sample {
                    Text("ABCDEFGHIJKLM\nNOPQRSTUVWXYZ\nabcdefghijklm\nnopqrstuvwxyz\n1234567890")
                        .multilineTextAlignment(.center)
                        .font(Font.custom(family.fontNames.first ?? "", size: family.displaySize * 2.0))
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: 400)
                } else {
                    #if targetEnvironment(macCatalyst) // Workaround for catalyst bug that screws up line height in TextEditor view.
                    Text("The quick brown fox jumps over the lazy dog and runs away.")
                        .multilineTextAlignment(.center)
                        .font(Font.custom(family.fontNames.first ?? "", size: family.displaySize * 2.0))
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: 400)
                    #else
                    TextEditor(text: $customString)
                        .multilineTextAlignment(.center)
                        .font(Font.custom(family.fontNames.first ?? "", size: family.displaySize * 2.0))
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: 400)
                    #endif
                }
                
                HStack(spacing: 8) {
                    Button {
                        if family.isRegistered {
                            CTFontManagerUnregisterFontURLs(family.fonts.map({ $0.fileURL }) as CFArray, .persistent) { (errors, done) -> Bool in
                                return true
                            }
                        } else {
                            CTFontManagerRegisterFontURLs(family.fonts.map({ $0.fileURL }) as CFArray, .persistent, true) { (errors, done) -> Bool in
                                return true
                            }
                        }
                    } label: {
                        if family.isRegistered {
                            Text("\(Image(systemName: "checkmark.circle")) Installed")
                                .font(Font.system(size: 20, weight: .medium, design: .default))
                                .frame(idealWidth: .infinity, maxWidth: .infinity)
                        } else {
                            Text("Install")
                                .font(Font.system(size: 20, weight: .medium, design: .default))
                                .frame(idealWidth: .infinity, maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    #if !targetEnvironment(macCatalyst)
                    ShareLink(items: family.fonts, message: Text("Found in Sprite Catalog")) { item in
                        SharePreview("\(family.name) \(item.style)")
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(Font.system(size: 20, weight: .medium, design: .default))
                            .frame(width: 20, height: 24)
                    }
                    #endif
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                LabeledValue(value: family.author.name, label: "Author", url: family.author.url)
                LabeledValue(value: "\(family.capHeight) px", label: "Cap Height")
                LabeledValue(value: family.licence.rawValue, label: "Licence")
            }
            .padding()
        }
        .navigationTitle(family.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: customString) {
            if customString.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if customString.isEmpty {
                        customString = Sprite_CatalogApp.defaultFontTestString
                    }
                }
            }
        }
    }
}

struct FontDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyDetailView(previewMode: .constant(.sample), customString: .constant("Quick fox."), family: FontFamily.allFamilies[0])
    }
}
