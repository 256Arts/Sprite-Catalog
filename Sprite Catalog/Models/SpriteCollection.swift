//
//  SpriteCollection.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-06-26.
//

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

class SpriteCollection: ObservableObject, Identifiable, Hashable, Codable {
    
    enum SaveStickersError: Error {
        case failedToGetSharedContainer
        case failedToCreateImageData
    }
    
    static let valentines = SpriteCollection(title: "Valentines", spriteIDs: [
        "cq1ad7", "zda2dz", "n9c7pd", "prj2s4", "3jlt4r", "0yvqu8", "ck9rbu", "lz3pg3", "c7y0m0"
    ])
    static let halloween = SpriteCollection(title: "Halloween", spriteIDs: [
        "zvajed", "blwzvs", "8zp5p2", "cmnxlh", "3e1dpr", "ph35o7", "jzk054", "9j6wc2", "bjsdw9", "ft47q8", "ye6y3c", "0nf5sx", "1c5oy5", "1jci5y", "9vq48v"
    ])
    static let holiday = SpriteCollection(title: "Holiday", spriteIDs: [
        "smj06m", "gcnurp", "odupla", "w07osw", "sefdb8", "ae618d", "q1kviw", "csfaud", "9v67gn", "e3wy8x", "v96mkq", "1m6dj0", "6mt7nr", "8ahit0", "8pglcg", "9m95pa", "549xzg", "adz6xg", "bbhaea", "d2npq0", "fh7lxw", "j02nvg", "jc6r1c", "kin7jw", "mbhiwa", "n84ggg", "p8nyy3", "p44aqu", "pi4i4j", "rc5isg", "t99meb", "v3kr54", "vfifh9", "vml3e3", "w6dmsy", "plnmdq", "s31gl3", "86me7y"
    ])
    static var featured: [SpriteCollection] = {
        var main = [
            SpriteCollection(title: "Sci-Fi", spriteIDs: [
                "skc2i5", "2ncn60", "s726dy", "4auq90", "mary61", "hj8230", "79wuc1", "zctmaf", "mysmvl", "1zt0rx", // Helmets
                "evshvr", "o8wlp3", "ncpzx6", "z8zjo0", "1bam97", "m8rel3", "lttcws", "2pxex5", "g8y77x", "49f4az", // Ships
                "gmyeoz", "jl2h5z", "h50eti", "388kpy", "6xakrf", "60lvey", "r7zh8a", "drv4w1", "aou4mh", "btd0ey", "c3zyzk", // Items
                "1pukv8", "3das2j", "e5sb2a", "tj2ooi", "wox5pa", "wu1wq0", "zuzoh5", // Buildings
                "3nltpr", "9qcuoi", "9vdgrg", "a8w695", "afrngu", "axt3ao", "c2hx4m", "gu5z6o", "hx18ma", "i75gy4", "i24632", "iq3tuz", "jaejn1", "o4wys0", "pw2bvc", "qn500i", "qposgk", "r1kra2", "rfe19i", "t7vxee", "xgbexm", // Planets
                "i0w3fv", "ljae9g", "nvkuxc", "o3y7mq", "pgalyo", "sbge1q", "sy7tul", "tg4l0z" // Artwork
            ]),
            SpriteCollection(title: "Paintings", spriteIDs: [
                "7w0rvr", "1t8yd1", "ccb3aq", "67abpb", "r7fmqy", "sbxv7d", "9j2uzy", "g068bp", "3jlwtg", "e73m5i", "dr4is5", "oh5iiw", "ds7zh8", "ifp6u0", "3b1i39"
            ])
        ]
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 2:
            main.insert(SpriteCollection.valentines, at: 0)
        case 10:
            main.insert(SpriteCollection.halloween, at: 0)
        case 12:
            main.insert(SpriteCollection.holiday, at: 0)
        default:
            break
        }
        return main
    }()
    static let gaming: [SpriteCollection] = [
        SpriteCollection(title: "Playstation", spriteIDs: [
            "u9z9xw", "krhcxa", "3wytcy", "cdahls", "v7cw7l", "7jkphr", "yfex44", "colb2b", "bf1brv", "28777r", "6l5pb3", "27bi6h", "mv6ot1", "kwa1jy", "uwbpxi", "axder5", "u3ttkm", "dn1kdn", "n6yty5", "a1bfb5", "cxkqva", "sg561c", "q64p7n", "ubo92g", "kdszaz", "80483r", "37ekkt"
        ]),
        SpriteCollection(title: "Switch", spriteIDs: [
            "dybcy4", "izzymr", "czek6s", "72xmlz", "2m064q", "i6gyco", "6uh0zh", "897f4n", "zd1ova", "jruf9e", "5g2w1h", "axder5", "u3ttkm", "dn1kdn", "n6yty5", "a1bfb5", "cxkqva", "sg561c", "q64p7n", "kdszaz", "ubo92g", "l19cem", "2skudb", "8h0igi", "adb7d3"
        ]),
        SpriteCollection(title: "Xbox", spriteIDs: [
            "dybcy4", "izzymr", "czek6s", "72xmlz", "ylk8v4", "tylner", "edb7xj", "7bhxgy", "5iuy1w", "k6gqrc", "q8h40z", "51pg2k", "ubo92g", "axder5", "u3ttkm", "dn1kdn", "n6yty5", "a1bfb5", "cxkqva", "sg561c", "q64p7n", "kdszaz", "ey4vai", "xpvvip", "8d7uo4", "fvn325", "w00tzq", "8h0igi", "adb7d3"
        ]),
        SpriteCollection(title: "Apple TV", spriteIDs: [
            "dybcy4", "izzymr", "czek6s", "72xmlz", "q8h40z", "ubo92g", "axder5", "u3ttkm", "dn1kdn", "n6yty5", "a1bfb5", "cxkqva", "sg561c", "q64p7n", "kdszaz", "xpvvip", "8d7uo4", "fvn325", "w00tzq", "z9v626", "2m064q", "5g2w1h", "8h0igi", "adb7d3"
        ]),
        SpriteCollection(title: "Mac", spriteIDs: [
            "ym58wf", "7a7z99", "cgp5ob", "h5zzrz", "si54xe", "qy1xvm", "21og7z", "61il5v", "bo573c", "sjc3k1", "ztfyy1", "ins9mr", "pf69ts"
        ]),
        SpriteCollection(title: "PC", spriteIDs: [
            "ym58wf", "7a7z99", "cgp5ob", "h5zzrz", "si54xe", "qy1xvm", "21og7z", "3zkfcx", "bo573c", "sjc3k1", "ztfyy1", "ur68kh", "zd0eaz"
        ])
    ]
    
    static let myCollectionFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("My Collection").appendingPathExtension("json")
    static let stickersCollectionFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Stickers Collection").appendingPathExtension("json")
    
    static var myCollection: SpriteCollection = {
        (try? JSONDecoder().decode(SpriteCollection.self, from: Data(contentsOf: SpriteCollection.myCollectionFileURL))) ?? SpriteCollection(title: "My Collection", spriteIDs: [])
    }()
    static var stickersCollection: SpriteCollection = {
        (try? JSONDecoder().decode(SpriteCollection.self, from: Data(contentsOf: SpriteCollection.stickersCollectionFileURL))) ?? SpriteCollection(title: "iMessage Stickers", spriteIDs: [])
    }()
    
    static func == (lhs: SpriteCollection, rhs: SpriteCollection) -> Bool {
        lhs.title == rhs.title && lhs.spriteIDs == rhs.spriteIDs
    }
    
    let title: String
    var id: String {
        title
    }
    
    var spriteIDs: Set<String> {
        willSet {
            objectWillChange.send()
        }
    }
    var sprites: [SpriteSet] {
        SpriteSet.allSprites.filter({ spriteIDs.contains($0.id) })
    }
    
    init(title: String, spriteIDs: Set<String>) {
        self.title = title
        self.spriteIDs = spriteIDs
    }
    
    init(artist: Artist) {
        self.title = artist.name
        self.spriteIDs = Set(SpriteSet.allSprites.filter({ $0.artist == artist }).map({ $0.id }))
    }
    
    func save(to url: URL) throws {
        let data = try JSONEncoder().encode(self)
        try data.write(to: url, options: .atomic)
    }
    
    func saveStickers() throws {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: messagesAppGroupID) else {
            throw SaveStickersError.failedToGetSharedContainer
        }
        
        // Remove all old files
        do {
            let properties: [URLResourceKey] = [.localizedNameKey, .creationDateKey, .localizedTypeDescriptionKey]
            let oldURLs = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: properties, options: .skipsHiddenFiles)
            for url in oldURLs {
                if url.pathExtension == "png" {
                    try FileManager.default.removeItem(at: url)
                }
            }
        } catch { print(error) }
        
        // Save all new files
        for sprite in sprites {
            #if canImport(UIKit)
            guard let data = UIImage(named: sprite.tiles.first!.variants.first!.imageName)?.pngData() else {
                throw SaveStickersError.failedToCreateImageData
            }
            #else
            guard let data = NSImage(named: sprite.tiles.first!.variants.first!.imageName)?.pngData() else {
                throw SaveStickersError.failedToCreateImageData
            }
            #endif
            try data.write(to: containerURL.appendingPathComponent(sprite.id).appendingPathExtension("png"))
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(spriteIDs)
    }
    
}
