//
//  FontItem.swift
//  Sprite Fonts
//
//  Created by 256 Arts Developer on 2021-02-15.
//

import SwiftUI
import CoreGraphics

enum FontLicence: String, CaseIterable, Identifiable {
    case publicDomain = "Public Domain"
    case free = "Free"
    case freeForPersonal = "Free for Personal Use"
    var id: Self {
        self
    }
}

struct FontFamily: Hashable, Identifiable {
    
    struct Font: Transferable {
        
        enum FileType: String {
            case ttf, otf
        }
        
        static var transferRepresentation: some TransferRepresentation {
            FileRepresentation(exportedContentType: .font) {
                SentTransferredFile($0.fileURL)
            }
        }
        
        let style: String
        let fileURL: URL
        
        init(style: String, fileName: String, fileType: FileType) {
            self.style = style
            self.fileURL = Bundle.main.url(forResource: fileName, withExtension: fileType.rawValue)!
        }
    }
    
    struct Author {
        let name: String
        let url: URL?
    }
    
    enum Tag: String, CaseIterable, Identifiable {
        case bold = "Bold"
        case ultraBold = "Ultra Bold"
        case italic = "Italic"
        case modern = "Modern"
        case outline = "Outline / Shadow"
        case serif = "Serif"
        case weird = "Weird"
        case fun = "Fun"
        case sciFi = "Sci-Fi"
        case handwritting = "Handwritting"
        case monospaced = "Monospaced"
        case lowercaseIncluded = "Lowercase Included"
        case installed = "Installed"
        
        var id: Tag { self }
    }
    
    let name: String
    var id: String {
        name
    }
    let author: Author
    let licence: FontLicence
    let capHeight: Int
    let displaySize: CGFloat
    let fonts: [Font]
    
    private let staticTags: [Tag]
    var tags: [Tag] {
        if isRegistered {
            return staticTags + [.installed]
        } else {
            return staticTags
        }
    }
    
    var fontNames: [String] {
        UIFont.fontNames(forFamilyName: name)
    }
    var isRegistered: Bool {
        FontProvider.shared.registeredFamilies.contains(name)
    }
    
    init(name: String, author: Author, licence: FontLicence, capHeight: Int, displaySize: CGFloat, tags: [Tag], fonts: [Font]) {
        self.name = name
        self.author = author
        self.licence = licence
        self.capHeight = capHeight
        self.displaySize = displaySize
        self.staticTags = tags
        self.fonts = fonts
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FontFamily, rhs: FontFamily) -> Bool {
        lhs.id == rhs.id
    }
    
    func exportFontDocuments() -> [FontDocument] {
        fonts.map({ FontDocument(font: $0, filename: "\(name) \($0.style)") })
    }
    
    static let allFamilies = [
    FontFamily(name: "8-bit Arcade In", author: Author(name: "Damien Gosset", url: nil), licence: .free, capHeight: 5, displaySize: 35, tags: [.bold, .ultraBold], fonts: [
            Font(style: "Medium", fileName: "8-bit Arcade In", fileType: .ttf)
        ]),
    FontFamily(name: "8-bit Arcade Out", author: Author(name: "Damien Gosset", url: nil), licence: .free, capHeight: 6, displaySize: 35, tags: [.bold, .ultraBold, .outline], fonts: [
            Font(style: "Medium", fileName: "8-bit Arcade Out", fileType: .ttf)
        ]),
    FontFamily(name: "Alkhemikal", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 27, tags: [.bold, .weird, .serif, .lowercaseIncluded], fonts: [
            Font(style: "Medium", fileName: "Alkhemikal", fileType: .ttf)
        ]),
    FontFamily(name: "AprilSans", author: Author(name: "typesprite", url: nil), licence: .publicDomain, capHeight: 8, displaySize: 32, tags: [.serif, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "AprilSans", fileType: .otf)
        ]),
    FontFamily(name: "BasicHandwriting", author: Author(name: "NoahK", url: nil), licence: .publicDomain, capHeight: 12, displaySize: 25, tags: [.bold, .handwritting, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "BasicHandwriting", fileType: .ttf)
        ]),
    FontFamily(name: "BetterPixels", author: Author(name: "AmericanHamster", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 32, tags: [.modern, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "BetterPixels", fileType: .ttf)
        ]),
    FontFamily(name: "BitCasual", author: Author(name: "geoff", url: nil), licence: .publicDomain, capHeight: 8, displaySize: 28, tags: [.modern, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "BitCasual", fileType: .ttf)
        ]),
    FontFamily(name: "blocks", author: Author(name: "robertfortanier", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 32, tags: [.bold, .ultraBold, .weird, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "blocks", fileType: .ttf)
        ]),
    FontFamily(name: "Born2bSporty", author: Author(name: "JapanYoshi", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 28, tags: [.bold, .modern, .fun, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Born2bSporty", fileType: .ttf)
        ]),
    FontFamily(name: "Code", author: Author(name: "J D", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 27, tags: [.bold, .serif, .monospaced, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Code", fileType: .ttf)
        ]),
    FontFamily(name: "Comicoro", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 40, tags: [.handwritting, .lowercaseIncluded], fonts: [
            Font(style: "Medium", fileName: "Comicoro", fileType: .ttf)
        ]),
    FontFamily(name: "CursivePixel", author: Author(name: "JapanYoshi", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 28, tags: [.lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "CursivePixel", fileType: .ttf)
        ]),
    FontFamily(name: "CyborgSister", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 8, displaySize: 31, tags: [.lowercaseIncluded], fonts: [
            Font(style: "Medium", fileName: "CyborgSister", fileType: .ttf)
        ]),
    FontFamily(name: "DigitalDisco", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 25, tags: [.bold, .lowercaseIncluded], fonts: [
            Font(style: "Medium", fileName: "DigitalDisco Thin", fileType: .ttf),
            Font(style: "Thin", fileName: "DigitalDisco", fileType: .ttf)
        ]),
    FontFamily(name: "Disrespectful", author: Author(name: "JayWright", url: nil), licence: .publicDomain, capHeight: 16, displaySize: 22, tags: [.bold, .weird, .handwritting], fonts: [
            Font(style: "Regular", fileName: "Disrespectful", fileType: .ttf)
        ]),
    FontFamily(name: "Dogica", author: Author(name: "Roberto Mocci", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 18, tags: [.bold, .modern, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Dogica", fileType: .ttf),
            Font(style: "Bold", fileName: "Dogica Bold", fileType: .ttf)
        ]),
    FontFamily(name: "ElfBoyClassic", author: Author(name: "heaven castro", url: nil), licence: .free, capHeight: 7, displaySize: 37, tags: [.bold, .ultraBold, .outline, .weird, .fun], fonts: [
            Font(style: "Regular", fileName: "ElfBoyClassic", fileType: .ttf)
        ]),
    FontFamily(name: "EnterCommand", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 34, tags: [.bold, .italic, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "EnterCommand", fileType: .ttf),
            Font(style: "Bold", fileName: "EnterCommand Bold", fileType: .ttf),
            Font(style: "Italic", fileName: "EnterCommand Italic", fileType: .ttf),
        ]),
    FontFamily(name: "European Teletext", author: Author(name: "Jayvee Enaguas", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 26, tags: [.bold, .monospaced, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "European Teletext", fileType: .ttf),
            Font(style: "Nuevo", fileName: "European Teletext Nuevo", fileType: .ttf)
        ]),
        FontFamily(name: "Extrude", author: Author(name: "Nic", url: nil), licence: .publicDomain, capHeight: 12, displaySize: 30, tags: [.bold, .outline, .fun], fonts: [
            Font(style: "Regular", fileName: "Extrude", fileType: .ttf)
        ]),
    FontFamily(name: "Forma", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 31, tags: [.bold, .ultraBold, .weird], fonts: [
            Font(style: "Regular", fileName: "Forma", fileType: .ttf)
        ]),
    FontFamily(name: "Generic Mobile System", author: Author(name: "Jayvee Enaguas", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 26, tags: [.bold, .outline, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Generic Mobile System", fileType: .ttf),
            Font(style: "Nuevo", fileName: "Generic Mobile System Nuevo", fileType: .ttf),
            Font(style: "Regular O", fileName: "Generic Mobile System O", fileType: .ttf),
            Font(style: "Nuevo O", fileName: "Generic Mobile System Nuevo O", fileType: .ttf)
        ]),
    FontFamily(name: "Generic", author: Author(name: "AlphaNumericLlama", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 28, tags: [.lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Generic", fileType: .ttf)
        ]),
    FontFamily(name: "Gothic Pixel", author: Author(name: "Sparkletastic", url: nil), licence: .free, capHeight: 9, displaySize: 32, tags: [.serif, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Gothic Pixel", fileType: .ttf)
        ]),
    FontFamily(name: "Half Eighties", author: Author(name: "Jayvee Enaguas", url: nil), licence: .free, capHeight: 6, displaySize: 36, tags: [.bold, .monospaced, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Half Eighties", fileType: .ttf)
        ]),
    FontFamily(name: "HelvetiPixel", author: Author(name: "pentacom", url: nil), licence: .publicDomain, capHeight: 8, displaySize: 32, tags: [.modern, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "HelvetiPixel", fileType: .ttf)
        ]),
    FontFamily(name: "ImpactBits", author: Author(name: "JapanYoshi", url: nil), licence: .publicDomain, capHeight: 11, displaySize: 26, tags: [.bold, .ultraBold, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "ImpactBits", fileType: .ttf)
        ]),
    FontFamily(name: "ISL_ONYX", author: Author(name: "Isurus Labs", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 20, tags: [.modern, .sciFi], fonts: [
            Font(style: "Regular", fileName: "ISL_ONYX", fileType: .ttf)
        ]),
    FontFamily(name: "justabit", author: Author(name: "Alex Sheyn", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 28, tags: [.sciFi, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "justabit", fileType: .ttf)
        ]),
    FontFamily(name: "Kapel", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 35, tags: [.bold, .fun, .sciFi, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Kapel", fileType: .ttf)
        ]),
    FontFamily(name: "KarenBook", author: Author(name: "Paul Spades", url: nil), licence: .publicDomain, capHeight: 8, displaySize: 29, tags: [.bold, .serif, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "KarenBook", fileType: .ttf)
        ]),
    FontFamily(name: "KiwiSoda", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 11, displaySize: 28, tags: [.bold, .weird, .fun, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "KiwiSoda", fileType: .ttf)
        ]),
    FontFamily(name: "ldcBlackRound", author: Author(name: "lagdotcom", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 27, tags: [.bold, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "ldcBlackRound", fileType: .ttf)
        ]),
    FontFamily(name: "littleLightPixel", author: Author(name: "Paul Spades", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 34, tags: [.lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "littleLightPixel", fileType: .ttf)
        ]),
    FontFamily(name: "LycheeSoda", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 8, displaySize: 32, tags: [.bold, .weird, .fun, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "LycheeSoda", fileType: .ttf)
        ]),
    FontFamily(name: "MeleeSans", author: Author(name: "ArkanadeEidos", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 32, tags: [.bold, .outline, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "MeleeSans", fileType: .ttf)
        ]),
    FontFamily(name: "Minimal4", author: Author(name: "Saint11", url: nil), licence: .publicDomain, capHeight: 4, displaySize: 60, tags: [.monospaced, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Minimal4", fileType: .ttf)
        ]),
    FontFamily(name: "Minitel", author: Author(name: "Frédéric Bisson", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 22, tags: [.serif, .monospaced, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Minitel", fileType: .ttf)
        ]),
    FontFamily(name: "Notepen", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 32, tags: [.handwritting, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Notepen", fileType: .ttf)
        ]),
    FontFamily(name: "OldWizard", author: Author(name: "Angel", url: nil), licence: .publicDomain, capHeight: 10, displaySize: 28, tags: [.bold, .serif, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "OldWizard", fileType: .ttf)
        ]),
    FontFamily(name: "Oskool", author: Author(name: "tulamide", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 38, tags: [.bold, .weird, .fun, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Oskool", fileType: .ttf)
        ]),
    FontFamily(name: "OwlsNInk", author: Author(name: "DubzyWubzyUbzy", url: nil), licence: .publicDomain, capHeight: 11, displaySize: 27, tags: [.bold, .handwritting], fonts: [
            Font(style: "Regular", fileName: "OwlsNInk", fileType: .ttf)
        ]),
    FontFamily(name: "OwreKynge", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 30, tags: [.bold, .weird, .serif, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "OwreKynge", fileType: .ttf)
        ]),
    FontFamily(name: "PearSoda", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 34, tags: [.bold, .weird, .fun], fonts: [
            Font(style: "Regular", fileName: "PearSoda", fileType: .ttf)
        ]),
    FontFamily(name: "Piacevoli", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 40, tags: [.serif, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Piacevoli", fileType: .ttf)
        ]),
    FontFamily(name: "Pixeled", author: Author(name: "OmegaPC777", url: nil), licence: .free, capHeight: 6, displaySize: 16, tags: [.lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Pixeled", fileType: .ttf)
        ]),
    FontFamily(name: "Pixellari", author: Author(name: "Zacchary Dempsey-Plante", url: nil), licence: .free, capHeight: 11, displaySize: 24, tags: [.bold, .modern, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Pixellari", fileType: .ttf)
        ]),
    FontFamily(name: "PixelMechaBold", author: Author(name: "HuseyinAlperTUNA", url: nil), licence: .publicDomain, capHeight: 12, displaySize: 26, tags: [.bold, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "PixelMechaBold", fileType: .ttf)
        ]),
    FontFamily(name: "Pixerif", author: Author(name: "Thamaszz", url: nil), licence: .publicDomain, capHeight: 8, displaySize: 34, tags: [.serif, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Pixerif", fileType: .ttf)
        ]),
    FontFamily(name: "PixieKid", author: Author(name: "SQUiDS", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 34, tags: [.bold, .fun, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "PixieKid", fileType: .ttf)
        ]),
    FontFamily(name: "PlanetaryContact", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 5, displaySize: 26, tags: [.bold, .weird, .sciFi, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "PlanetaryContact", fileType: .ttf)
        ]),
    FontFamily(name: "Press Start 2P", author: Author(name: "Codeman38", url: nil), licence: .free, capHeight: 7, displaySize: 18, tags: [.bold, .monospaced, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Press Start 2P", fileType: .ttf)
        ]),
    FontFamily(name: "PxArt", author: Author(name: "EmilMG", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 40, tags: [.outline, .fun], fonts: [
            Font(style: "Regular", fileName: "PxArt", fileType: .ttf)
        ]),
    FontFamily(name: "RobotY", author: Author(name: "castpixel", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 40, tags: [.bold, .outline, .weird], fonts: [
            Font(style: "Regular", fileName: "RobotY", fileType: .ttf)
        ]),
    FontFamily(name: "Silverfinster", author: Author(name: "heaven castro", url: nil), licence: .free, capHeight: 4, displaySize: 26, tags: [.lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Silverfinster", fileType: .ttf)
        ]),
    FontFamily(name: "SirClive", author: Author(name: "Giles Booth", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 35, tags: [.weird, .sciFi, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "SirClive", fileType: .ttf)
        ]),
    FontFamily(name: "SquareSounds", author: Author(name: "iLKke", url: nil), licence: .publicDomain, capHeight: 5, displaySize: 40, tags: [.weird, .sciFi, .monospaced], fonts: [
            Font(style: "Regular", fileName: "SquareSounds", fileType: .ttf)
        ]),
    FontFamily(name: "Squarewave", author: Author(name: "jeti", url: nil), licence: .publicDomain, capHeight: 7, displaySize: 36, tags: [.bold, .italic, .sciFi, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "Squarewave", fileType: .ttf),
            Font(style: "Italic", fileName: "Squarewave Italic", fileType: .ttf),
            Font(style: "Bold", fileName: "Squarewave Bold", fileType: .ttf)
        ]),
    FontFamily(name: "SylladexFanon", author: Author(name: "MetaXing", url: nil), licence: .publicDomain, capHeight: 8, displaySize: 34, tags: [.lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "SylladexFanon", fileType: .ttf)
        ]),
    FontFamily(name: "TheWall", author: Author(name: "Extant", url: nil), licence: .publicDomain, capHeight: 13, displaySize: 28, tags: [.handwritting, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "TheWall", fileType: .ttf)
        ]),
    FontFamily(name: "TimesNewPixel", author: Author(name: "pentacom", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 28, tags: [.serif, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "TimesNewPixel", fileType: .ttf)
        ]),
    FontFamily(name: "TomAndJerry", author: Author(name: "StePickford", url: nil), licence: .publicDomain, capHeight: 13, displaySize: 23, tags: [.bold, .ultraBold, .fun], fonts: [
            Font(style: "Regular", fileName: "TomAndJerry", fileType: .ttf)
        ]),
    FontFamily(name: "VCR OSD Mono", author: Author(name: "Riciery Leal", url: nil), licence: .free, capHeight: 14, displaySize: 26, tags: [.monospaced, .lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "VCR OSD Mono", fileType: .ttf)
        ]),
    FontFamily(name: "W95FA", author: Author(name: "FontsArena", url: nil), licence: .publicDomain, capHeight: 9, displaySize: 26, tags: [.lowercaseIncluded], fonts: [
            Font(style: "Regular", fileName: "W95FA", fileType: .otf)
        ]),
//    FontFamily(name: <#T##String#>, author: Author(name: <#T##String#>, url: nil), licence: .publicDomain, capHeight: <#T##Int#>, displaySize: 28, tags: <#T##[Tag]#>, fonts: [
//            Font(style: "Regular", fileName: <#T##String#>, fileType: .ttf)
//        ]),
    ]
    
}
